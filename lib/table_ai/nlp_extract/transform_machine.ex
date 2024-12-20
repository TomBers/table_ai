defmodule TableAi.NlpExtract.TransformMachine do
  def return_results(res, df, take \\ 5) do
    run_filters(res, df) |> Enum.take(take) |> Enum.map(&Enum.to_list(&1))
  end

  def emit_results(query, pid) do
    formatted_rows = TableAi.FlowProcessing.FlowCsv.process_file(query.file_path, query.steps)

    send(pid, {:rows, formatted_rows})
  end

  def run_filters(res, df) do
    res
    |> Enum.reduce(df, fn
      res, acc ->
        case res do
          %{"method" => "filter_row"} ->
            expanded_filters = expand_filters(res["filters"])
            acc |> filter_row(res["row_index"], expanded_filters)

          %{"method" => "fillter_row_by_range"} ->
            case res["column_type"] do
              "date" ->
                from_date = Date.from_iso8601!(res["from"])
                to_date = Date.from_iso8601!(res["to"])
                acc |> filter_by_date(res["column_index"], from_date, to_date)

              "timestamp" ->
                {:ok, from_dt, _} = DateTime.from_iso8601(res["from"])
                {:ok, to_dt, _} = DateTime.from_iso8601(res["to"])
                acc |> filter_by_timestamp(res["column_index"], from_dt, to_dt)

              "int" ->
                from_int = res["from"]
                to_int = res["to"]
                acc |> filter_by_int(res["column_index"], from_int, to_int)

              "float" ->
                from_float = res["from"]
                to_float = res["to"]
                acc |> filter_by_float(res["column_index"], from_float, to_float)
            end

          %{"method" => "filter_column"} ->
            acc |> filter_column(res["columns"])

          %{"method" => "limit"} ->
            # Assume first row is the header
            limit = res["number"]

            acc
            |> order_by_column(res["column_index"], res["column_type"], res["order"])
            |> Enum.take(limit)
        end
    end)
  end

  def expand_filters(terms) do
    terms
    |> Enum.flat_map(fn term ->
      caps = String.split(term, " ") |> Enum.map(&String.capitalize/1) |> Enum.join(" ")
      [term, String.upcase(term), String.downcase(term), :string.titlecase(term), caps]
    end)
    |> MapSet.new()
  end

  def filter_row(data, row_index, filters) do
    Stream.filter(data, fn row ->
      Enum.any?(filters, fn filter -> String.contains?(Enum.at(row, row_index), filter) end)
      # MapSet.member?(filters, Enum.at(row, row_index))
    end)
  end

  def filter_column(data, columns) do
    data |> Stream.map(fn row -> extact_columns(row, columns) end)
  end

  def filter_by_date(data, column_index, from_date, to_date) do
    Stream.filter(data, fn row ->
      case Enum.at(row, column_index) |> Date.from_iso8601() do
        {:ok, date} -> Date.after?(date, from_date) and Date.before?(date, to_date)
        _ -> false
      end
    end)
  end

  def order_by_column(data, column_index, ~c"date", order) do
    data
    |> Enum.sort_by(
      fn row ->
        case Date.from_iso8601(Enum.at(row, column_index)) do
          {:ok, date} -> date
          _ -> Date.from_iso8601("0000-01-01")
        end
      end,
      {String.to_atom(order), Date}
    )
  end

  def order_by_column(data, column_index, ~c"timestamp", order) do
    data
    |> Enum.sort_by(
      fn row ->
        case DateTime.from_iso8601(Enum.at(row, column_index)) do
          {:ok, datetime, _} -> datetime
          _ -> DateTime.from_iso8601("0000-01-01T00:00:00Z")
        end
      end,
      {String.to_atom(order), DateTime}
    )
  end

  def order_by_column(data, column_index, ~c"int") do
    # IO.inspect("Order by Int")

    data
    |> Enum.sort_by(
      fn row ->
        {val, _} = Integer.parse(Enum.at(row, column_index))
        val
      end,
      # Use the Kernel comparison operator
      &Kernel.>=/2
    )
  end

  def order_by_column(data, column_index, ~c"float") do
    # IO.inspect("Order by Float")

    data
    |> Enum.sort_by(
      fn row ->
        Float.parse(Enum.at(row, column_index))
      end,
      &Kernel.>=/2
    )
  end

  def order_by_column(data, column_index, column_type, order) do
    # IO.inspect(column_type, label: "Order by Col")

    data
    |> Enum.sort_by(
      fn row ->
        Enum.at(row, column_index)
      end,
      String.to_atom(order)
    )
  end

  def parse_date(val) do
    case Date.from_iso8601(val) do
      {:ok, date} -> date
      _ -> nil
    end
  end

  def get_errors(data, column_index, type) do
    case type do
      "date" -> type_errors(data, column_index, type, &Date.from_iso8601/1)
      "int" -> type_errors(data, column_index, type, &Integer.parse/1)
      "float" -> type_errors(data, column_index, type, &Float.parse/1)
      "timestamp" -> type_errors(data, column_index, type, &DateTime.from_iso8601/1)
      _ -> []
    end
  end

  def type_errors(data, column_index, type, conv_fn) do
    data
    |> Stream.with_index()
    |> Stream.filter(fn {row, _row_index} ->
      case Enum.at(row, column_index) |> conv_fn.() do
        {:error, _} ->
          true

        _ ->
          false
      end
    end)
    |> Stream.map(fn {row, row_index} ->
      %{
        row_index: row_index,
        column_index: column_index,
        error: "Invalid " <> type,
        data: Enum.at(row, column_index)
      }
    end)
    |> Stream.reject(fn row -> row.row_index == 0 end)
  end

  def filter_by_timestamp(data, column_index, from_dt, to_dt) do
    Stream.filter(data, fn row ->
      case Enum.at(row, column_index) |> DateTime.from_iso8601() do
        {:ok, dt, _} -> DateTime.after?(dt, from_dt) and DateTime.before?(dt, to_dt)
        _ -> false
      end
    end)
  end

  def filter_by_int(data, column_index, from_int, to_int) do
    # IO.inspect("Filter by Int")

    Stream.filter(data, fn row ->
      case Enum.at(row, column_index) |> Integer.parse() do
        {int, _} -> int >= from_int and int <= to_int
        _ -> false
      end
    end)
    |> order_by_column(column_index, ~c"int")
  end

  def filter_by_float(data, column_index, from_float, to_float) do
    # IO.inspect("Filter by Float")

    Stream.filter(data, fn row ->
      case Enum.at(row, column_index) |> Float.parse() do
        {float, _} -> float >= from_float and float <= to_float
        _ -> false
      end
    end)
    |> order_by_column(column_index, ~c"float")
  end

  def extact_columns(row, columns) do
    Stream.map(columns, fn col -> Enum.at(row, col) end)
  end

  def fix_errors(errors, df) do
    errors
    |> Enum.reduce(df, fn error, acc ->
      row_index = error["row_index"]
      column_index = error["column_index"]
      data = error["fixed_data"]
      fix_error(acc, row_index, column_index, data)
    end)
  end

  defp fix_error(df, row_index, col_index, new_data) do
    # Convert the stream to a list if it's not already a list
    df_list = if is_list(df), do: df, else: Enum.to_list(df)

    # Retrieve the row as a list
    row = Enum.at(df_list, row_index)

    # Ensure the row is a list
    row_list = if is_list(row), do: row, else: Enum.to_list(row)

    # Replace the element at the specified column index in the row
    updated_row = List.replace_at(row_list, col_index, new_data)

    # Replace the old row with the updated row in the DataFrame
    List.replace_at(df_list, row_index, updated_row)
  end
end

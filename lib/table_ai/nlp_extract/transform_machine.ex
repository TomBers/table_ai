defmodule TableAi.NlpExtract.TransformMachine do
  def return_results(res, df, take \\ 5) do
    run_filters(res, df) |> Enum.take(take) |> Enum.map(&(Enum.to_list(&1) |> Enum.join(", ")))
  end

  def emit_results(res, df, pid) do
    run_filters(res, df)
    |> Stream.chunk_every(500)
    |> Stream.each(fn rows ->
      formatted_rows =
        Enum.map(rows, fn row ->
          row
          |> Enum.to_list()
          |> Enum.join(", ")
        end)

      send(pid, {:rows, formatted_rows})
    end)
    |> Stream.run()
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
            acc |> Stream.take(res["number"])
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

  def filter_by_int(data, column_index, from_int, to_int) do
    Stream.filter(data, fn row ->
      case Enum.at(row, column_index) |> Integer.parse() do
        {int, _} -> int >= from_int and int <= to_int
        _ -> false
      end
    end)
  end

  def filter_by_float(data, column_index, from_float, to_float) do
    Stream.filter(data, fn row ->
      case Enum.at(row, column_index) |> Float.parse() do
        {float, _} -> float >= from_float and float <= to_float
        _ -> false
      end
    end)
  end

  def extact_columns(row, columns) do
    Stream.map(columns, fn col -> Enum.at(row, col) end)
  end
end

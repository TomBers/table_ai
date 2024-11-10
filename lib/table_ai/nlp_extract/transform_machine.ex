defmodule TableAi.NlpExtract.TransformMachine do
  def return_results(res, df, take \\ 5) do
    run_filters(res, df) |> Enum.take(take) |> Enum.map(&(Enum.to_list(&1) |> Enum.join(", ")))
  end

  def emit_results(res, df, pid) do
    run_filters(res, df)
    |> Stream.chunk_every(200)
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
    |> Enum.reduce(df, fn res, acc ->
      case res do
        %{"method" => "filter_row"} ->
          expanded_filters = expand_filters(res["filters"])
          acc |> filter_row(res["row_index"], expanded_filters)

        %{"method" => "filter_by_date"} ->
          from_date = Date.from_iso8601!(res["from_date"])
          to_date = Date.from_iso8601!(res["to_date"])
          acc |> filter_by_date(res["column_index"], from_date, to_date)

        %{"method" => "filter_column"} ->
          acc |> filter_column(res["columns"])
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
      MapSet.member?(filters, Enum.at(row, row_index))
    end)
  end

  def filter_column(data, columns) do
    data |> Stream.map(fn row -> extact_columns(row, columns) end)
  end

  def filter_by_date(data, column_index, from_date, to_date) do
    Stream.filter(data, fn row ->
      date = Enum.at(row, column_index) |> Date.from_iso8601!()
      Date.after?(date, from_date) and Date.before?(date, to_date)
    end)
  end

  def extact_columns(row, columns) do
    Stream.map(columns, fn col -> Enum.at(row, col) end)
  end
end

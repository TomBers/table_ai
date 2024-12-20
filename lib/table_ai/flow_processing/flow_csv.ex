defmodule TableAi.FlowProcessing.FlowCsv do
  alias TableAi.NlpExtract.TransformMachine
  alias TableAi.DataFix.FixErrors

  def run do
    path = "priv/static/uploads/imdb"
    process_file(path, steps())
  end

  def process_file(filename, steps) do
    # Get number of available cores
    # total_lines = File.stream!(filename) |> Enum.count()
    pool_size = System.schedulers_online()

    result =
      filename
      |> File.stream!()
      |> CSV.decode!()
      |> Flow.from_enumerable(stages: pool_size)
      |> Flow.map_batch(fn rows ->
        df = TransformMachine.run_filters(steps, rows) |> Enum.to_list()
        errors = FixErrors.get_errors(steps, rows)

        if length(df) > 0 do
          [%{data: df, errors: errors}]
        else
          []
        end
      end)
      |> Flow.reduce(fn -> [] end, fn row, acc ->
        [row | acc]
      end)
      |> Enum.to_list()

    %{
      data: Enum.flat_map(result, &Map.get(&1, :data)),
      errors: Enum.flat_map(result, &Map.get(&1, :errors))
    }
  end

  def steps do
    [
      %{
        "column_index" => 6,
        "column_type" => "int",
        "from" => 1960,
        "method" => "fillter_row_by_range",
        "to" => 1969
      },
      %{
        "column_index" => 4,
        "column_type" => "float",
        "from" => 7,
        "method" => "fillter_row_by_range",
        "to" => nil
      },
      %{"filters" => ["London"], "method" => "filter_row", "row_index" => 1}
    ]
  end
end

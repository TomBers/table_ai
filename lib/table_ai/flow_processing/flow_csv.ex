defmodule TableAi.FlowProcessing.FlowCsv do
  alias TableAi.NlpExtract.TransformMachine

  def run do
    path = "priv/static/uploads/imdb"
    process_file(path, steps())
  end

  def process_file(filename, steps) do
    # Get number of available cores
    # total_lines = File.stream!(filename) |> Enum.count()
    pool_size = System.schedulers_online()

    filename
    |> File.stream!()
    |> CSV.decode!()
    |> Flow.from_enumerable(stages: pool_size)
    |> Flow.map_batch(fn rows ->
      TransformMachine.run_filters(steps, rows) |> Enum.to_list()
    end)
    |> Flow.reduce(fn -> [] end, fn row, acc ->
      [row | acc]
    end)
    |> Enum.to_list()
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

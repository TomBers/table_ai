defmodule TableAi.FlowProcessing.FlowCsv do
  def run do
    path = "priv/static/uploads/imdb"
    process_file(path, steps())
    # IO.inspect(System.schedulers_online())
  end

  def process_file(filename, steps) do
    # Get number of available cores
    pool_size = System.schedulers_online()

    filename
    |> File.stream!([], :line)
    |> CSV.decode!()
    |> Flow.from_enumerable(max_demand: 10000, stages: pool_size)
    # |> Flow.partition(stages: pool_size)
    |> Flow.map_batch(fn rows ->
      # Your row processing logic here
      process_row(rows, steps)
    end)
    |> Flow.reduce(fn -> [] end, fn row, acc ->
      # Now we're explicitly using a list accumulator
      [row | acc]
    end)
    |> Enum.to_list()
    |> IO.inspect(label: "Results")

    # |> Enum.to_list()

    # |> List.flatten()

    "Done"
  end

  defp process_row(rows, steps) do
    # Define your row processing logic
    # Example:
    TableAi.NlpExtract.TransformMachine.run_filters(steps, rows) |> Enum.to_list()
  end

  defp combine_results(row, acc) do
    # Define how to combine results from different workers
    # Example:
    Map.merge(acc, %{row["id"] => row})
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

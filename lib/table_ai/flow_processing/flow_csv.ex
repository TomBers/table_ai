defmodule TableAi.FlowProcessing.FlowCsv do
  alias TableAi.NlpExtract.TransformMachine
  alias TableAi.DataFix.FixErrors

  def run do
    # path = "priv/static/uploads/imdb"
    # process_file(path, imdb_steps())
    path = "priv/static/uploads/error_correct"
    process_file(path, error_steps(), fixed_errors())
  end

  def process_file(filename, steps, fixed_errors \\ []) do
    # total_lines = File.stream!(filename) |> Enum.count()
    # Get number of available cores
    pool_size = System.schedulers_online()

    result =
      filename
      |> File.stream!()
      |> CSV.decode!()
      |> Flow.from_enumerable(stages: pool_size)
      |> Flow.map_batch(fn rows ->
        fixed_rows =
          case fixed_errors do
            [] -> rows
            _ -> TransformMachine.fix_errors(fixed_errors, rows)
          end

        dataframe = TransformMachine.run_filters(steps, fixed_rows) |> Enum.to_list()

        errors = FixErrors.get_errors(steps, fixed_rows)

        case dataframe do
          [] -> []
          _ -> [%{data: dataframe, errors: errors}]
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

  def imdb_steps do
    [
      %{
        "column_index" => 6,
        "column_type" => "int",
        "from" => 1960,
        "method" => "filter_row_by_range",
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

  def error_steps do
    [
      %{
        "column_index" => 10,
        "column_type" => "date",
        "from" => "2022-01-01",
        "method" => "filter_row_by_range",
        "to" => "2023-01-01"
      }
    ]
  end

  def fixed_errors do
    [
      %{"column_index" => 10, "fixed_data" => "2024-03-25", "row_index" => 3},
      %{"column_index" => 10, "fixed_data" => "2025-01-17", "row_index" => 10},
      %{"column_index" => 10, "fixed_data" => "2025-06-07", "row_index" => 92}
    ]
  end
end

defmodule TableAi.FloatTest do
  use ExUnit.Case
  alias TableAi.NlpExtract.{DataLoader, TransformMachine}
  @limit 100
  # Testing various transformation engine rules for CSV file
  def load_csv() do
    file_path = "test/table_ai/test.csv"
    DataLoader.file(file_path)
  end

  def filter_float_range do
    [
      %{
        "column_index" => 14,
        "column_type" => "float",
        "from" => 100.0,
        "method" => "fillter_row_by_range",
        "to" => 500.0
      }
    ]
  end

  def limit_float do
    [
      %{
        "column_index" => 14,
        "column_type" => "float",
        "method" => "limit",
        "number" => 10,
        "order" => "desc"
      }
    ]
  end

  test "filter_datetime_range" do
    df = load_csv()
    steps = filter_float_range()

    res =
      TransformMachine.return_results(steps, df, @limit)
      |> IO.inspect(label: "Float range results")

    assert length(res) == 40
  end

  test "limit_datetime" do
    df = load_csv()
    steps = limit_float()

    res =
      TransformMachine.return_results(steps, df, @limit)
      |> IO.inspect(label: "Float Limit results")

    assert length(res) == 10
  end
end

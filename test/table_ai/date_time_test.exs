defmodule TableAi.DateTimeTest do
  use ExUnit.Case
  alias TableAi.NlpExtract.{DataLoader, TransformMachine}
  @limit 100
  # Testing various transformation engine rules for CSV file
  def load_csv() do
    file_path = "test/table_ai/test.csv"
    DataLoader.file(file_path, @limit)
  end

  def filter_datetime_range do
    [
      %{
        "column_index" => 12,
        "column_type" => "timestamp",
        "from" => "2024-11-23 12:00:00Z",
        "method" => "fillter_row_by_range",
        "to" => "2024-11-23 12:45:00Z"
      }
    ]
  end

  def limit_datetime do
    [
      %{
        "column_index" => 12,
        "column_type" => "timestamp",
        "method" => "limit",
        "number" => 10,
        "order" => "desc"
      }
    ]
  end

  test "filter_datetime_range" do
    df = load_csv()
    steps = filter_datetime_range()

    res = TransformMachine.return_results(steps, df, @limit) |> IO.inspect(label: "Timestamps")

    assert length(res) == 45
  end

  test "limit_datetime" do
    df = load_csv()
    steps = limit_datetime()

    res = TransformMachine.return_results(steps, df, @limit) |> IO.inspect(label: "Limit results")
    assert length(res) == 10
  end
end

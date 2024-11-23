defmodule TableAi.IntTest do
  use ExUnit.Case
  alias TableAi.NlpExtract.{DataLoader, TransformMachine}
  @limit 100
  # Testing various transformation engine rules for CSV file
  def load_csv() do
    file_path = "test/table_ai/test.csv"
    DataLoader.file(file_path)
  end

  def filter_int_range do
    [
      %{
        "column_index" => 13,
        "column_type" => "int",
        "from" => 100,
        "method" => "fillter_row_by_range",
        "to" => 500
      }
    ]
  end

  def limit_int do
    [
      %{
        "column_index" => 13,
        "column_type" => "int",
        "method" => "limit",
        "number" => 10,
        "order" => "desc"
      }
    ]
  end

  test "filter_datetime_range" do
    df = load_csv()
    steps = filter_int_range()

    res =
      TransformMachine.return_results(steps, df, @limit)
      |> IO.inspect(label: "int range results")

    assert length(res) == 34
  end

  test "limit_datetime" do
    df = load_csv()
    steps = limit_int()

    res =
      TransformMachine.return_results(steps, df, @limit)
      |> IO.inspect(label: "int Limit results")

    assert length(res) == 10
  end
end

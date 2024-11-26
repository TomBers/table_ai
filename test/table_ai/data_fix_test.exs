defmodule DataFixTest do
  use ExUnit.Case

  alias TableAi.NlpExtract.{DataLoader, TransformMachine}
  alias TableAi.DataFix.AutoFixer

  # @limit 100
  # Testing various transformation engine rules for CSV file
  def load_csv() do
    file_path = "test/table_ai/test_errors.csv"
    DataLoader.file(file_path)
  end

  def filter_date_steps do
    [
      %{
        "column_index" => 10,
        "column_type" => "date",
        "from" => "2021-01-01",
        "method" => "fillter_row_by_range",
        "to" => "2023-01-01"
      }
    ]
  end

  def limit_steps do
    [
      %{
        "column_index" => 10,
        "column_type" => "date",
        "method" => "limit",
        "number" => 10,
        "order" => "desc"
      }
    ]
  end

  test "filter_row_by_range" do
    df = load_csv()
    res = filter_date_steps()

    range_filter =
      Enum.find(res, fn step ->
        step["method"] == "fillter_row_by_range" || step["method"] == "limit"
      end)

    errors =
      TransformMachine.get_errors(df, range_filter["column_index"], range_filter["column_type"])
      |> Enum.to_list()
      |> IO.inspect(label: "errors")

    assert length(errors) == 2

    fixed_df =
      AutoFixer.example_fixer(errors)
      |> TransformMachine.fix_errors(df)

    fixed_errors =
      TransformMachine.get_errors(
        fixed_df,
        range_filter["column_index"],
        range_filter["column_type"]
      )
      |> Enum.to_list()
      |> IO.inspect(label: "Fixed errors")

    assert length(fixed_errors) == 0
  end

  test "limit" do
    df = load_csv()
    res = limit_steps()

    range_filter =
      Enum.find(res, fn step ->
        step["method"] == "fillter_row_by_range" || step["method"] == "limit"
      end)

    errors =
      TransformMachine.get_errors(df, range_filter["column_index"], range_filter["column_type"])
      |> Enum.to_list()
      |> IO.inspect(label: "errors")

    assert length(errors) == 2

    fixed_df =
      AutoFixer.example_fixer(errors)
      |> TransformMachine.fix_errors(df)

    fixed_errors =
      TransformMachine.get_errors(
        fixed_df,
        range_filter["column_index"],
        range_filter["column_type"]
      )
      |> Enum.to_list()
      |> IO.inspect(label: "Fixed errors")

    assert length(fixed_errors) == 0
  end
end

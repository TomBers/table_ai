defmodule CSVTest do
  use ExUnit.Case

  alias TableAi.NlpExtract.{DataLoader, TransformMachine}

  @limit 100
  # Testing various transformation engine rules for CSV file
  def load_csv() do
    file_path = "test/table_ai/test.csv"
    DataLoader.file(file_path)
  end

  test "filter_row" do
    df = load_csv()
    steps = filter_row()

    res = TransformMachine.return_results(steps, df, @limit)
    assert length(res) == 16
  end

  test "filter_range" do
    df = load_csv()
    steps = filter_range()

    res = TransformMachine.return_results(steps, df, @limit)
    assert length(res) == 62
  end

  test "filter_column" do
    df = load_csv()
    steps = filter_column()

    res = TransformMachine.return_results(steps, df, @limit)
    assert length(res) == 100
    assert Enum.at(res, 0) == ["First Name", "Last Name", "Email"]
    assert Enum.at(res, 1) |> length() == 3
  end

  test "limit" do
    df = load_csv()
    steps = limit()

    res = TransformMachine.return_results(steps, df, @limit)
    assert length(res) == 10
    first = res |> List.first() |> Enum.at(10)
    last = res |> List.last() |> Enum.at(10)
    assert Date.after?(Date.from_iso8601!(first), Date.from_iso8601!(last))
  end

  test "multiple_steps" do
    df = load_csv()
    steps = limit()

    res = TransformMachine.return_results(steps, df, @limit)
    assert length(res) == 10
  end

  def filter_row do
    [
      %{
        "filters" => [
          "United Kingdom",
          "France",
          "Germany",
          "Italy",
          "Spain",
          "Netherlands",
          "Belgium",
          "Sweden",
          "Denmark",
          "Ireland",
          "Portugal",
          "Finland",
          "Poland",
          "Austria",
          "Switzerland",
          "Norway",
          "Greece",
          "Hungary",
          "Czech Republic",
          "Romania",
          "Luxembourg",
          "Slovakia",
          "Bulgaria",
          "Croatia",
          "Slovenia",
          "Estonia",
          "Latvia",
          "Lithuania",
          "Cyprus",
          "Malta",
          "Iceland",
          "Liechtenstein",
          "Monaco",
          "San Marino",
          "Andorra",
          "Vatican City"
        ],
        "method" => "filter_row",
        "row_index" => 6
      }
    ]
  end

  def filter_range do
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

  def filter_column do
    [
      %{
        "columns" => [2, 3, 9],
        "method" => "filter_column"
      }
    ]
  end

  def limit do
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

  def multiple_steps do
    # Can you get me company and email of the last 10 people to signup from Europe?
    [
      %{
        "filters" => [
          "United Kingdom",
          "France",
          "Germany",
          "Italy",
          "Spain",
          "Netherlands",
          "Belgium",
          "Sweden",
          "Denmark",
          "Ireland",
          "Portugal",
          "Finland",
          "Poland",
          "Austria",
          "Switzerland",
          "Norway",
          "Greece",
          "Hungary",
          "Czech Republic",
          "Romania",
          "Luxembourg",
          "Slovakia",
          "Bulgaria",
          "Croatia",
          "Slovenia",
          "Estonia",
          "Latvia",
          "Lithuania",
          "Cyprus",
          "Malta",
          "Iceland",
          "Liechtenstein",
          "Monaco",
          "San Marino",
          "Andorra",
          "Vatican City"
        ],
        "method" => "filter_row",
        "row_index" => 6
      },
      %{
        "column_index" => 10,
        "column_type" => "date",
        "method" => "limit",
        "number" => 10,
        "order" => "desc"
      },
      %{"columns" => [0, 4, 9, 10, 11], "method" => "filter_column"}
    ]
  end
end

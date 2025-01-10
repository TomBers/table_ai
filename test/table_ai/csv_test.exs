defmodule CSVTest do
  use ExUnit.Case

  # TODO - the Limit function removes the first row, which is the header.
  # Think about making it more consistent with the other functions.
  # Either extract headers before all functions or after all functions.

  alias TableAi.NlpExtract.{DataLoader, TransformMachine}

  @limit 100
  # Testing various transformation engine rules for CSV file
  def load_csv() do
    file_path = "test/table_ai/test.csv"
    DataLoader.file(file_path, @limit)
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
    assert length(res) == 60
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

    res = TransformMachine.return_results(steps, df, @limit) |> IO.inspect(label: "Limit results")

    assert length(res) == 10
    [_ | data] = res
    # Extract the dates from the results
    dates =
      data
      |> Enum.map(&Enum.at(&1, 10))
      |> Enum.map(&Date.from_iso8601!/1)

    # |> IO.inspect(label: "Dates")

    # Check that each date is greater than or equal to the previous one
    case Enum.reduce_while(dates, nil, fn
           date, nil ->
             {:cont, date}

           date, prev_date ->
             if Date.compare(prev_date, date) != :lt do
               {:cont, date}
             else
               {:halt, {:error, prev_date, date}}
             end
         end) do
      nil ->
        flunk("The dates list is empty.")

      {:error, prev_date, date} ->
        flunk("Dates are out of order: #{prev_date} is after #{date}.")

      _last_date ->
        :ok
    end
  end

  test "multiple_steps" do
    df = load_csv()
    steps = multiple_steps()

    res =
      TransformMachine.return_results(steps, df, @limit) |> IO.inspect(label: "Multiple Steps")

    assert length(res) == 10
    assert Enum.at(res, 0) |> length == 5

    first = res |> List.first() |> Enum.at(3)
    last = res |> List.last() |> Enum.at(3)
    assert Date.after?(Date.from_iso8601!(first), Date.from_iso8601!(last))
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
        "method" => "filter_row_by_range",
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

defmodule TableAi.NlpExtract.TransformSteps do
  def example_steps do
    # Can I get name and email from the last 5 customers from Europe
    [
      %{
        "filters" => [
          "United Kingdom",
          "Germany",
          "France",
          "Italy",
          "Spain",
          "Netherlands",
          "Greece",
          "Sweden",
          "Poland",
          "Belgium",
          "Finland",
          "Denmark",
          "Ireland",
          "Portugal",
          "Austria",
          "Hungary",
          "Czech Republic",
          "Romania",
          "Bulgaria",
          "Slovakia",
          "Croatia",
          "Estonia",
          "Slovenia",
          "Latvia",
          "Lithuania",
          "Luxembourg",
          "Malta",
          "Cyprus"
        ],
        "method" => "filter_row",
        "row_index" => 6
      },
      %{"method" => "limit", "number" => 5},
      %{"columns" => [2, 3, 9], "method" => "filter_column"}
    ]

    # "Can you get me all the info for customers who joined between 2021 and 2023"

    [
      %{
        "column_index" => 10,
        "column_type" => "date",
        "from" => "2021-01-01",
        "method" => "fillter_row_by_range",
        "to" => "2023-01-01"
      }
    ]

    # Get Last 5 customers who signed up
    [
      %{
        "column_index" => 10,
        "column_type" => "date",
        "method" => "limit",
        "number" => 5,
        "order" => "desc"
      }
    ]

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

  def get_headers(res, columns) do
    cols =
      res
      |> Enum.find(fn x -> x["method"] == "filter_column" end)

    case cols do
      nil ->
        columns |> String.split(",")

      _ ->
        cols
        |> Map.get("columns")
        |> Enum.map(fn x -> Enum.at(columns, x) end)
    end
  end
end

defmodule TableAi.OpenaiExtract do
  def example_steps(file_name) do
    case file_name do
      "imdb" -> imdb()
      "customers" -> customers()
      "error_correct" -> error_correct()
      _ -> []
    end
  end

  def error_correct do
    # "Can you get me all the info for customers who joined between 2021 and 2023"
    [
      %{
        "column_index" => 10,
        "column_type" => "date",
        "from" => "2022-05-01",
        "method" => "filter_row_by_range",
        "to" => "2026-01-01"
      }
    ]
  end

  def customers do
    # Can I get contact details from the last 10 customers from Europe
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
      %{
        "column_index" => 10,
        "column_type" => "date",
        "method" => "limit",
        "number" => 10,
        "order" => "desc"
      },
      %{"columns" => [2, 3, 4, 6, 9, 10], "method" => "filter_column"}
    ]
  end

  def imdb do
    # Get me the top 10 horror movies from the 1980s where the number of votes is greater than 1000
    [
      %{"filters" => ["movie"], "method" => "filter_row", "row_index" => 2},
      %{"filters" => ["horror"], "method" => "filter_row", "row_index" => 3},
      %{
        "column_index" => 6,
        "column_type" => "int",
        "from" => 1980,
        "method" => "filter_row_by_range",
        "to" => 1989
      },
      %{
        "column_index" => 5,
        "column_type" => "int",
        "from" => 1001,
        "method" => "filter_row_by_range",
        "to" => 1_000_000
      },
      %{
        "column_index" => 4,
        "column_type" => "float",
        "method" => "limit",
        "number" => 10,
        "order" => "desc"
      }
    ]

    # Get me the top 10 highest rated comedy tv shows with number of votes is greater than 1000
    # [
    #   %{"filters" => ["tvMiniSeries", "tvSeries"], "method" => "filter_row", "row_index" => 2},
    #   %{"filters" => ["Comedy"], "method" => "filter_row", "row_index" => 3},
    #   %{
    #     "column_index" => 5,
    #     "column_type" => "int",
    #     "from" => 1000,
    #     "method" => "filter_row_by_range",
    #     "to" => 1_000_000
    #   },
    #   %{
    #     "column_index" => 4,
    #     "column_type" => "float",
    #     "method" => "limit",
    #     "number" => 10,
    #     "order" => "desc"
    #   },
    #   %{"columns" => [0, 1, 2, 3, 4, 5, 6], "method" => "filter_column"}
    # ]
  end

  def extract_steps_from_response(response) do
    response.body["choices"]
    |> hd()
    |> Map.get("message")
    |> Map.get("content")
    |> Jason.decode!()
    |> Map.get("steps")
  end
end

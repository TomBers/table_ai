defmodule TableAi.OpenaiExtract do
  def example_steps do
    # Get me the top 10 horror movies from the 1980s where the number of votes is greater than 100
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
        "from" => 101,
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
    [
      %{"filters" => ["tvMiniSeries", "tvSeries"], "method" => "filter_row", "row_index" => 2},
      %{"filters" => ["Comedy"], "method" => "filter_row", "row_index" => 3},
      %{
        "column_index" => 5,
        "column_type" => "int",
        "from" => 1000,
        "method" => "filter_row_by_range",
        "to" => 1_000_000
      },
      %{
        "column_index" => 4,
        "column_type" => "float",
        "method" => "limit",
        "number" => 10,
        "order" => "desc"
      },
      %{"columns" => [0, 1, 2, 3, 4, 5, 6], "method" => "filter_column"}
    ]
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

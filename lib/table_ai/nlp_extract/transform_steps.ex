defmodule TableAi.NlpExtract.TransformSteps do
  alias OpenaiEx.Chat
  alias OpenaiEx.ChatMessage

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

    [
      %{
        "column_index" => 10,
        "column_type" => "date",
        "method" => "limit",
        "number" => 5,
        "order" => "desc"
      }
    ]
  end

  def get_headers(res, columns) do
    cols =
      res
      |> Enum.find(fn x -> x["method"] == "filter_column" end)

    case cols do
      nil ->
        columns

      _ ->
        cols
        |> Map.get("columns")
        |> Enum.map(fn x -> Enum.at(columns, x) end)
    end
  end

  def get(prompt, transform_instructions) do
    apikey = System.fetch_env!("OPENAI_API_KEY")
    llm = OpenaiEx.new(apikey) |> OpenaiEx.with_receive_timeout(45_000)

    chat_req =
      Chat.Completions.new(
        # model: "chatgpt-4o-latest",
        model: "gpt-4o-2024-08-06",
        messages: [
          ChatMessage.system(transform_instructions),
          ChatMessage.user(prompt)
        ]
      )

    chat_response = llm |> Chat.Completions.create(chat_req)

    case chat_response do
      {:ok, chat_response} ->
        IO.inspect(chat_response)
        get_response(chat_response)

      {:error, error} ->
        error
    end
  end

  defp get_response(chat_response) do
    chat_response["choices"]
    |> hd()
    |> get_in(["message", "content"])
    |> String.replace_prefix("```json", "")
    |> String.replace_suffix("```", "")
    |> Jason.decode()
  end
end

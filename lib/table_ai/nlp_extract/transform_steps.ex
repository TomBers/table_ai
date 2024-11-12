defmodule TableAi.NlpExtract.TransformSteps do
  alias OpenaiEx.Chat
  alias OpenaiEx.ChatMessage

  def example_steps do
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
          "Switzerland",
          "Norway",
          "Denmark",
          "Finland",
          "Ireland",
          "Austria",
          "Portugal",
          "Greece",
          "Czech Republic",
          "Poland",
          "Hungary",
          "Luxembourg"
        ],
        "method" => "filter_row",
        "row_index" => 6
      },
      %{"columns" => [2, 3, 4, 6, 9], "method" => "filter_column"}
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

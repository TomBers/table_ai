defmodule TableAi.LlmInterface do
  alias OpenaiEx.Chat
  alias OpenaiEx.ChatMessage

  def get(prompt, transform_instructions) do
    apikey = System.fetch_env!("OPENAI_API_KEY")
    llm = OpenaiEx.new(apikey) |> OpenaiEx.with_receive_timeout(45_000)

    # model = "gpt-4o-mini-2024-07-18"
    model = "gpt-4o-2024-08-06"
    # model: "chatgpt-4o-latest",

    chat_req =
      Chat.Completions.new(
        model: model,
        messages: [
          ChatMessage.system(transform_instructions),
          ChatMessage.user(prompt)
        ],
        # TODO - maybe set make tokens for request to prevent cutting off responses
        max_tokens: 1500
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

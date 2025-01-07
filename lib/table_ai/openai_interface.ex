defmodule TableAi.OpenaiInterface do
  def solve_math_problem do
    url = "https://api.openai.com/v1/chat/completions"

    body = %{
      model: "gpt-4o-2024-08-06",
      messages: [
        %{
          role: "system",
          content:
            "You are a helpful math tutor. Guide the user through the solution step by step."
        },
        %{
          role: "user",
          content: "how can I solve 8x + 7 = -23"
        }
      ],
      response_format: %{
        type: "json_schema",
        json_schema: %{
          name: "math_reasoning",
          schema: %{
            type: "object",
            properties: %{
              steps: %{
                type: "array",
                items: %{
                  type: "object",
                  properties: %{
                    explanation: %{type: "string"},
                    output: %{type: "string"}
                  },
                  required: ["explanation", "output"],
                  additionalProperties: false
                }
              },
              final_answer: %{type: "string"}
            },
            required: ["steps", "final_answer"],
            additionalProperties: false
          },
          strict: true
        }
      }
    }

    headers = [
      {"Authorization", "Bearer #{System.get_env("OPENAI_API_KEY")}"},
      {"Content-Type", "application/json"}
    ]

    Req.post!(url,
      headers: headers,
      json: body
    )
  end
end

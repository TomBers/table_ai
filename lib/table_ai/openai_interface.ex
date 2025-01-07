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
          schema: %{
            type: "object",
            properties: %{
              steps: %{
                type: "array",
                items: %{
                  type: "object",
                  properties: %{
                    method: %{
                      type: "string",
                      description: "The method to apply to the data.",
                      enum: [
                        "fillter_row_by_range",
                        "filter_row",
                        "filter_column",
                        "limit"
                      ]
                    },
                    column_type: %{
                      type: "anyOf",
                      description:
                        "The type of the column to filter by. Can be one of ['date', 'timestamp', 'int', 'string' or 'float']."
                    },
                    column_index: %{
                      type: "integer",
                      description: "The index of the column to apply the filter on."
                    },
                    from: %{type: "anyOf", description: "The start for the filter."},
                    to: %{type: "anyOf", description: "The end for the filter."},
                    filters: %{
                      type: "array",
                      items: %{type: "anyOf"},
                      description: "The list of values to filter by."
                    },
                    row_index: %{type: "integer", description: "The index of the row"}
                  },
                  required: ["method"],
                  additionalProperties: false
                }
              }
            },
            required: ["steps"],
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

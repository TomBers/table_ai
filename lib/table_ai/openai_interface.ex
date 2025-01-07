defmodule TableAi.OpenaiInterface do
  alias TableAi.NlpExtract.SystemInstruction

  @url "https://api.openai.com/v1/chat/completions"
  @model "gpt-4o-2024-08-06"

  def test do
    prompt =
      "I have a spreadsheet with columns [id, title, type, genres, averageRating, numVotes, releaseYear] and the question ```Can you get me content from the 60s with rating higher than 7 with London in the title```."

    run(prompt)
  end

  def run(prompt) do
    transform_instructions = SystemInstruction.get()

    get_massages(prompt, transform_instructions)
    |> make_req()
  end

  def get_massages(prompt, transform_instructions) do
    [
      %{
        "role" => "developer",
        "content" => transform_instructions
      },
      %{
        "role" => "user",
        "content" => prompt
      }
    ]
  end

  def make_req(messages) do
    body = %{
      model: @model,
      messages: messages,
      response_format: response_format()
    }

    headers = [
      {"Authorization", "Bearer #{System.get_env("OPENAI_API_KEY")}"},
      {"Content-Type", "application/json"}
    ]

    Req.post!(@url,
      headers: headers,
      json: body
    )
  end

  def response_format do
    %{
      type: "json_schema",
      json_schema: %{
        name: "transformation_steps",
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
                      "filter_row_by_range",
                      "filter_row",
                      "filter_column",
                      "limit"
                    ]
                  },
                  column_type: %{
                    type: "string",
                    description:
                      "The type of the column to filter by. Can be one of ['date', 'timestamp', 'int', 'string' or 'float'].",
                    enum: ["date", "timestamp", "int", "string", "float"]
                  },
                  column_index: %{
                    type: "integer",
                    description: "The index of the column to apply the filter on."
                  },
                  from: %{
                    anyOf: [
                      %{
                        type: "string"
                      },
                      %{
                        type: "number"
                      },
                      %{
                        type: "integer"
                      }
                    ],
                    description: "The lower bound for the filter."
                  },
                  to: %{
                    anyOf: [
                      %{
                        type: "string"
                      },
                      %{
                        type: "number"
                      },
                      %{
                        type: "integer"
                      }
                    ],
                    description: "The upper bound for the filter."
                  },
                  filters: %{
                    type: "array",
                    items: %{
                      anyOf: [
                        %{
                          type: "string"
                        },
                        %{
                          type: "number"
                        },
                        %{
                          type: "integer"
                        }
                      ]
                    },
                    description: "The list of values to filter by."
                  },
                  row_index: %{type: "integer", description: "The index of the row"}
                },
                required: [
                  "method"
                  #   # "column_index",
                  #   # "row_index",
                  #   # "column_type",
                  #   # "from",
                  #   # "to",
                  #   # "filters"
                ],
                additionalProperties: false
              }
            }
          },
          required: ["steps"],
          additionalProperties: false
        },
        strict: false
      }
    }
  end
end

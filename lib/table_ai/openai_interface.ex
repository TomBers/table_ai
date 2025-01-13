defmodule TableAi.OpenaiInterface do
  alias TableAi.NlpExtract.SystemInstruction

  @url "https://api.openai.com/v1/chat/completions"
  # @model "gpt-4o-2024-08-06"
  # Updated to latest model
  @model "gpt-4o-2024-11-20"

  # Currently don't have access to o1 models'

  # TODO - test the different models
  @available_models [
    "gpt-4o-2024-08-06",
    "gpt-4o-2024-11-20",
    "chatgpt-4o-latest"
  ]

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
        # "role" => "developer",
        "role" => "user",
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
      response_format: json_schema()
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

  def json_schema do
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
                anyOf: [
                  %{
                    type: "object",
                    properties: %{
                      method: %{
                        type: "string",
                        description: "The method to apply to the data."
                      },
                      row_index: %{
                        type: "integer",
                        description: "The index of the row to apply the filter on."
                      },
                      filters: %{
                        type: "array",
                        items: %{
                          type: "string",
                          description: "The list of values to filter by."
                        },
                        description: "The list of values to filter by."
                      }
                    },
                    required: ["method", "row_index", "filters"]
                  },
                  %{
                    type: "object",
                    properties: %{
                      method: %{
                        type: "string",
                        description: "The method to apply to the data."
                      },
                      column_index: %{
                        type: "integer",
                        description: "The index of the column to apply the filter on."
                      },
                      column_type: %{
                        type: "string",
                        description:
                          "The type of the column to filter by. Can be one of ['date', 'timestamp', 'int', 'string' or 'float'].",
                        enum: ["date", "timestamp", "int", "string", "float"]
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
                        description: "The start for the filter"
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
                        description: "The end for the filter."
                      }
                    },
                    required: ["method", "column_index", "column_type", "from", "to"]
                  },
                  %{
                    type: "object",
                    properties: %{
                      method: %{
                        type: "string",
                        description: "The method to apply to the data."
                      },
                      columns: %{
                        type: "array",
                        items: %{
                          type: "integer",
                          description: "The indices of the columns to include."
                        },
                        description: "The indices of the columns to include."
                      }
                    },
                    required: ["method", "columns"]
                  },
                  %{
                    type: "object",
                    properties: %{
                      method: %{
                        type: "string",
                        description: "The method to apply to the data."
                      },
                      number: %{type: "integer", description: "The number of rows to return"},
                      column_index: %{
                        type: "integer",
                        description: "The index of the column to apply the on."
                      },
                      column_type: %{
                        type: "string",
                        description:
                          "The type of the column to filter by. Can be one of ['date', 'timestamp', 'int', 'string' or 'float'].",
                        enum: ["date", "timestamp", "int", "string", "float"]
                      },
                      order: %{
                        type: "string",
                        description:
                          "The order to sort the data. Can be one of ['asc' or 'desc'].",
                        enum: ["asc", "desc"]
                      }
                    },
                    required: ["method", "number", "column_index", "column_type", "order"]
                  }
                ],
                required: ["steps"],
                additionalProperties: false
              },
              strict: true
            }
          }
        }
      }
    }
  end

  # def response_format do
  #   %{
  #     type: "json_schema",
  #     json_schema: %{
  #       name: "transformation_steps",
  #       schema: %{
  #         type: "object",
  #         properties: %{
  #           steps: %{
  #             type: "array",
  #             items: %{
  #               type: "object",
  #               properties: %{
  #                 method: %{
  #                   type: "string",
  #                   description: "The method to apply to the data.",
  #                   enum: [
  #                     "filter_row",
  #                     "filter_row_by_range",
  #                     "filter_column",
  #                     "limit"
  #                   ]
  #                 },
  #                 column_type: %{
  #                   type: "string",
  #                   description:
  #                     "The type of the column to filter by. Can be one of ['date', 'timestamp', 'int', 'string' or 'float'].",
  #                   enum: ["date", "timestamp", "int", "string", "float"]
  #                 },
  #                 column_index: %{
  #                   type: "integer",
  #                   description: "The index of the column to apply the filter on."
  #                 },
  #                 from: %{
  #                   anyOf: [
  #                     %{
  #                       type: "string"
  #                     },
  #                     %{
  #                       type: "number"
  #                     },
  #                     %{
  #                       type: "integer"
  #                     }
  #                   ],
  #                   description: "The start for the filter"
  #                 },
  #                 to: %{
  #                   anyOf: [
  #                     %{
  #                       type: "string"
  #                     },
  #                     %{
  #                       type: "number"
  #                     },
  #                     %{
  #                       type: "integer"
  #                     }
  #                   ],
  #                   description: "The end for the filter."
  #                 },
  #                 columns: %{
  #                   type: "array",
  #                   items: %{
  #                     type: "integer",
  #                     description: "The indices of the columns to include."
  #                   },
  #                   description: "The indices of the columns to include."
  #                 },
  #                 filters: %{
  #                   type: "array",
  #                   items: %{
  #                     type: "string",
  #                     description: "The list of values to filter by."
  #                   },
  #                   description: "The list of values to filter by."
  #                 },
  #                 row_index: %{
  #                   type: "integer",
  #                   description: "The index of the row to apply the filter on."
  #                 },
  #                 number: %{type: "integer", description: "The number of rows to return"},
  #                 order: %{
  #                   type: "string",
  #                   description: "The order to sort the data. Can be one of ['asc' or 'desc'].",
  #                   enum: ["asc", "desc"]
  #                 }
  #               },
  #               required: [
  #                 "method"
  #                 #   # "column_index",
  #                 #   # "row_index",
  #                 #   # "column_type",
  #                 #   # "from",
  #                 #   # "to",
  #                 #   # "filters"
  #               ],
  #               additionalProperties: false
  #             }
  #           }
  #         },
  #         required: ["steps"],
  #         additionalProperties: false
  #       },
  #       strict: false
  #     }
  #   }
  # end
end

defmodule TableAi.OpenaiExtract do
  def run do
    # test_res() |> extract_steps_from_response()
    [
      %{
        "column_index" => 6,
        "column_type" => "int",
        "from" => 1960,
        "method" => "filter_row_by_range",
        "to" => 1969
      },
      # %{"filters" => ["movie"], "method" => "filter_row", "row_index" => 1},
      %{
        "column_index" => 4,
        "column_type" => "float",
        "method" => "limit",
        "number" => 5,
        "order" => "desc"
      }
    ]
  end

  def extract_steps_from_response(response) do
    response.body["choices"]
    |> hd()
    |> Map.get("message")
    |> Map.get("content")
    |> Jason.decode!()
    |> Map.get("steps")

    # |> Enum.reverse()
  end

  def test_res do
    %Req.Response{
      status: 200,
      headers: %{
        "access-control-expose-headers" => ["X-Request-ID"],
        "alt-svc" => ["h3=\":443\"; ma=86400"],
        "cf-cache-status" => ["DYNAMIC"],
        "cf-ray" => ["8fe61a4ed85c954a-LHR"],
        "connection" => ["keep-alive"],
        "content-type" => ["application/json"],
        "date" => ["Tue, 07 Jan 2025 18:45:06 GMT"],
        "openai-organization" => ["user-tykwkipm5vzfnri6xtnwj5c8"],
        "openai-processing-ms" => ["1740"],
        "openai-version" => ["2020-10-01"],
        "server" => ["cloudflare"],
        "set-cookie" => [
          "__cf_bm=xlQYMeSKn8a_J2W0T3hfdra2VTN2AOXP57LdisS4KNA-1736275506-1.0.1.1-705IlRfvBhA89dCYKFWjQSlvYawyFVwcLmDB3TMPCxlbh7s5c0AO8Q8vJ2Og6854_DeDgaqW0M6humT6ynqmOw; path=/; expires=Tue, 07-Jan-25 19:15:06 GMT; domain=.api.openai.com; HttpOnly; Secure; SameSite=None",
          "_cfuvid=nQF2wlL04hMtadYoeuaFWpA9I11EiVY9_BECKfYt01I-1736275506352-0.0.1.1-604800000; path=/; domain=.api.openai.com; HttpOnly; Secure; SameSite=None"
        ],
        "strict-transport-security" => ["max-age=31536000; includeSubDomains; preload"],
        "transfer-encoding" => ["chunked"],
        "x-content-type-options" => ["nosniff"],
        "x-ratelimit-limit-requests" => ["5000"],
        "x-ratelimit-limit-tokens" => ["800000"],
        "x-ratelimit-remaining-requests" => ["4999"],
        "x-ratelimit-remaining-tokens" => ["799307"],
        "x-ratelimit-reset-requests" => ["12ms"],
        "x-ratelimit-reset-tokens" => ["51ms"],
        "x-request-id" => ["req_e6e1dac000046c2bdbdbb8aad796119e"]
      },
      body: %{
        "choices" => [
          %{
            "finish_reason" => "stop",
            "index" => 0,
            "logprobs" => nil,
            "message" => %{
              "content" =>
                "{\"steps\":[{\"method\":\"filter_row\",\"row_index\":1,\"filters\":[\"London\"]},{\"method\":\"filter_row_by_range\",\"column_index\":6,\"column_type\":\"int\",\"from\":1960,\"to\":1969},{\"method\":\"filter_row_by_range\",\"column_index\":4,\"column_type\":\"float\",\"from\":7.0,\"to\":10.0}]}",
              "refusal" => nil,
              "role" => "assistant"
            }
          }
        ],
        "created" => 1_736_275_504,
        "id" => "chatcmpl-An8rYLr9DndAc2TQbD9mppFf1oFHR",
        "model" => "gpt-4o-2024-08-06",
        "object" => "chat.completion",
        "system_fingerprint" => "fp_5f20662549",
        "usage" => %{
          "completion_tokens" => 79,
          "completion_tokens_details" => %{
            "accepted_prediction_tokens" => 0,
            "audio_tokens" => 0,
            "reasoning_tokens" => 0,
            "rejected_prediction_tokens" => 0
          },
          "prompt_tokens" => 975,
          "prompt_tokens_details" => %{"audio_tokens" => 0, "cached_tokens" => 0},
          "total_tokens" => 1054
        }
      },
      trailers: %{},
      private: %{}
    }
  end
end

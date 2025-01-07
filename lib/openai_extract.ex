defmodule OpenaiExtract do
  def run do
    test_res() |> extract_steps_from_response()
  end

  def extract_steps_from_response(response) do
    response.body["choices"]
    |> hd()
    |> Map.get("message")
    |> Map.get("content")
    |> Jason.decode!()
    |> Map.get("steps")
    |> Enum.reverse()
  end

  def test_res do
    %Req.Response{
      status: 200,
      headers: %{
        "access-control-expose-headers" => ["X-Request-ID"],
        "alt-svc" => ["h3=\":443\"; ma=86400"],
        "cf-cache-status" => ["DYNAMIC"],
        "cf-ray" => ["8fe47574dd6248c3-LHR"],
        "connection" => ["keep-alive"],
        "content-type" => ["application/json"],
        "date" => ["Tue, 07 Jan 2025 13:57:53 GMT"],
        "openai-organization" => ["user-tykwkipm5vzfnri6xtnwj5c8"],
        "openai-processing-ms" => ["7090"],
        "openai-version" => ["2020-10-01"],
        "server" => ["cloudflare"],
        "set-cookie" => [
          "__cf_bm=L7EbCK38t7F2iPPHKfWwNEs7AzOTWjZaGnhBUhatzy0-1736258273-1.0.1.1-creQD0K2c1BQN8E.NZ2JievYAqTCqo4Tg7axbyAJNwJwcZXVMNYgv7zVQ1ihQS7NpL0z3Ksl3a5jJFfKbqU41w; path=/; expires=Tue, 07-Jan-25 14:27:53 GMT; domain=.api.openai.com; HttpOnly; Secure; SameSite=None",
          "_cfuvid=j9UcOWg_7zGqKPlMeOnWYcZApINqwne37iUv5.cPS9Y-1736258273593-0.0.1.1-604800000; path=/; domain=.api.openai.com; HttpOnly; Secure; SameSite=None"
        ],
        "strict-transport-security" => ["max-age=31536000; includeSubDomains; preload"],
        "transfer-encoding" => ["chunked"],
        "x-content-type-options" => ["nosniff"],
        "x-ratelimit-limit-requests" => ["5000"],
        "x-ratelimit-limit-tokens" => ["800000"],
        "x-ratelimit-remaining-requests" => ["4999"],
        "x-ratelimit-remaining-tokens" => ["799306"],
        "x-ratelimit-reset-requests" => ["12ms"],
        "x-ratelimit-reset-tokens" => ["51ms"],
        "x-request-id" => ["req_f54251ec024c0d7f55d3714042f8832a"]
      },
      body: %{
        "choices" => [
          %{
            "finish_reason" => "stop",
            "index" => 0,
            "logprobs" => nil,
            "message" => %{
              "content" =>
                "{\"steps\":[{\"filters\":[\"London\"],\"to\":\"\" ,\"from\":\"\" ,\"column_index\":1,\"column_type\":\"string\",\"method\":\"filter_row\"  ,\"row_index\":1},{\"filters\":[],\"to\":\"7\", \"from\":\"\" ,\"column_index\":4,\"column_type\":\"int\",\"method\":\"filter_row\"  ,\"row_index\":4},{\"filters\":[],\"to\":\"1969\", \"from\":\"1960\" ,\"column_index\":6,\"column_type\":\"int\",\"method\":\"filter_row\"  ,\"row_index\":6}]}",
              "refusal" => nil,
              "role" => "assistant"
            }
          }
        ],
        "created" => 1_736_258_270,
        "id" => "chatcmpl-An4NalpkDUAZvKuP1mbIijyIV2ccN",
        "model" => "gpt-4o-2024-08-06",
        "object" => "chat.completion",
        "system_fingerprint" => "fp_5f20662549",
        "usage" => %{
          "completion_tokens" => 114,
          "completion_tokens_details" => %{
            "accepted_prediction_tokens" => 0,
            "audio_tokens" => 0,
            "reasoning_tokens" => 0,
            "rejected_prediction_tokens" => 0
          },
          "prompt_tokens" => 933,
          "prompt_tokens_details" => %{"audio_tokens" => 0, "cached_tokens" => 0},
          "total_tokens" => 1047
        }
      },
      trailers: %{},
      private: %{}
    }
  end
end

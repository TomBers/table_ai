defmodule TableAi.DataFix.TestDates do
  def run do
    prompt = "These are the dates: #{dates() |> Enum.join(", ")}."
    instructions = TableAi.DataFix.SystemInstructions.get()

    # Regex expressions lead to invalid JSON at first glance.
    # Shows the complexity of generating DSL like Regex or SQL.

    TableAi.NlpExtract.TransformSteps.get(prompt, instructions)
  end

  def dates do
    [
      "2020-02-25 - on a thursday",
      "25-02-2020",
      "1st October, 2022",
      "11/11/24",
      "Thursday, 25th February 2021",
      "2020-02-25"
    ]
  end

  def jsn do
    "[\n  {\n    \"method\": \"fix_date\",\n    \"data\": [\"2020-02-25 - on a thursday\", \"2020-02-25\"],\n    \"regex\": ~r/^(\\d{4}-\\d{2}-\\d{2})/\n  },\n  {\n    \"method\": \"fix_date\",\n    \"data\": [\"25-02-2020\"],\n    \"regex\": ~r/^(\\d{2}-\\d{2}-\\d{4})/\n  },\n  {\n    \"method\": \"fix_date\",\n    \"data\": [\"1st October, 2022\"],\n    \"regex\": ~r/^(\\d{1,2}(st|nd|rd|th) \\w+, \\d{4})/\n  },\n  {\n    \"method\": \"fix_date\",\n    \"data\": [\"11/11/24\"],\n    \"regex\": ~r/^(\\d{2}\\/\\d{2}\\/\\d{2})/\n  },\n  {\n    \"method\": \"fix_date\",\n    \"data\": [\"Thursday\"],\n    \"regex\": ~r/^\\w+/\n  },\n  {\n    \"method\": \"fix_date\",\n    \"data\": [\"25th February 2021\"],\n    \"regex\": ~r/^(\\d{1,2}(st|nd|rd|th) \\w+ \\d{4})/\n  }\n]"
  end
end

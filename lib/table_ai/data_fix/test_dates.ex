defmodule TableAi.DataFix.TestDates do
  def run do
    _prompt = "These are the dates: #{dates() |> Enum.join(", ")}."
    _instructions = TableAi.DataFix.SystemInstructions.fix_dates()

    # TableAi.NlpExtract.TransformSteps.get(prompt, instructions)
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

  def results do
    [
      "2020-02-25",
      "2020-02-25",
      "2022-10-01",
      "2024-11-11",
      "2021-02-25",
      "2020-02-25"
    ]
  end
end

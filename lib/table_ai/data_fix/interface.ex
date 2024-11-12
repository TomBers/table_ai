defmodule TableAi.DataFix.Interface do
  alias TableAi.NlpExtract.{DataLoader, TransformMachine, TransformSteps}
  alias TableAi.DataFix.AutoFixer

  def run do
    df = DataLoader.file("priv/static/uploads/live_view_upload-1731265586-487875740739-7")

    columns = Enum.take(df, 1) |> Enum.at(0)

    res = TransformSteps.example_steps()

    range_filter = Enum.find(res, fn step -> step["method"] == "fillter_row_by_range" end)

    errors =
      TransformMachine.get_errors(df, range_filter["column_index"], range_filter["column_type"])

    llm_fixes = AutoFixer.run_fixer(errors)

    # TODO - send the errors to the LLM to get fixed errors, then update the original data frame and run the steps

    # Fix the errors before executing the transformation
    # table = df |> Enum.take(15)

    # TransformMachine.fix_errors(table, llm_fixes)
  end
end

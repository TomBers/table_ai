defmodule TableAi.DataFix.Interface do
  alias TableAi.NlpExtract.{DataLoader, TransformMachine, TransformSteps}
  alias TableAi.DataFix.AutoFixer

  def run do
    df = DataLoader.file("priv/static/uploads/live_view_upload-1731265586-487875740739-7")

    # columns = Enum.take(df, 1) |> Enum.at(0)

    res = TransformSteps.example_steps()

    # TODO - there might be multiple range filters, so we need to handle that
    range_filter = Enum.find(res, fn step -> step["method"] == "fillter_row_by_range" end)

    errors =
      TransformMachine.get_errors(df, range_filter["column_index"], range_filter["column_type"])
      |> Enum.to_list()

    results =
      if Enum.count(errors) > 0 do
        AutoFixer.run_fixer(errors)
        |> TransformMachine.fix_errors(df)
        |> TransformMachine.return_results(res, 100)
      else
        TransformMachine.return_results(df, res, 100)
      end

    IO.inspect(Enum.count(results))
  end
end

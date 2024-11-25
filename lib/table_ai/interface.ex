defmodule TableAi.Interface do
  alias TableAi.NlpExtract.{TransformMachine, TransformSteps, DataLoader}
  alias TableAi.Structs.NLPQuery
  alias TableAi.DataFix.AutoFixer

  def gen_rows(file_path, _query, pid) do
    df = DataLoader.file(file_path)

    columns = Enum.take(df, 1) |> Enum.at(0)
    # ------------
    # prompt =
    #   "I have a spreadsheet with columns [#{columns |> Enum.join(", ")}] and the question #{query}."

    # instructions = SystemInstruction.get()
    # {:ok, res} = TransformSteps.get(prompt, instructions)
    # ------------

    # FOR testing
    res = TransformSteps.example_steps()

    errors = get_errors(res, df)

    query = %NLPQuery{
      df: df,
      headers: TransformSteps.get_headers(res, columns),
      steps: res,
      errors: errors
    }

    # If no errors found, emit the results
    if Enum.count(query.errors) == 0 do
      TransformMachine.emit_results(query, pid)
    end

    query
  end

  def emit_results(query, pid) do
    TransformMachine.emit_results(query, pid)
  end

  def fix_errors(query, pid) do
    # AutoFixer.run_fixer(query.errors)
    fixed_df =
      AutoFixer.test_fixer(query.errors)
      |> TransformMachine.fix_errors(query.df)
      |> IO.inspect(label: "Fixed DF")

    %{query | df: fixed_df, errors: []}
    |> TransformMachine.emit_results(pid)
  end

  def get_errors(res, df) do
    range_filter =
      Enum.find(res, fn step ->
        step["method"] == "fillter_row_by_range" || step["method"] == "limit"
      end)

    TransformMachine.get_errors(df, range_filter["column_index"], range_filter["column_type"])
    |> Enum.to_list()
  end
end

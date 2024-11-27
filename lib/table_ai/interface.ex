defmodule TableAi.Interface do
  alias TableAi.NlpExtract.{TransformMachine, TransformSteps, DataLoader, SystemInstruction}
  alias TableAi.Structs.NLPQuery
  alias TableAi.DataFix.AutoFixer
  alias TableAi.LlmInterface

  @use_test_data Application.compile_env(:table_ai, :use_test_data)

  def gen_rows(file_path, query, pid, file_name \\ nil) do
    # imdb_length = 1_031_289
    df = DataLoader.file(file_path)

    columns = Enum.take(df, 1) |> Enum.at(0)
    # First row seems to make the results worse
    # first_row = Enum.take(df, 2) |> Enum.at(1) |> Enum.join(", ")

    prompt =
      "I have a spreadsheet with columns [#{columns |> Enum.join(", ")}] and the question ```#{query}```."

    # IO.inspect(prompt, label: "Prompt")

    res =
      if @use_test_data do
        TransformSteps.example_steps(file_name)
      else
        instructions = SystemInstruction.get()
        {:ok, steps} = LlmInterface.get(prompt, instructions)
        steps
      end

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
    fixes =
      if @use_test_data do
        AutoFixer.example_fixer(query.errors)
      else
        AutoFixer.run_fixer(query.errors)
      end

    IO.inspect(fixes, label: "Fixes")

    # AutoFixer.run_fixer(query.errors)
    [_ | fixed_df] =
      fixes
      |> TransformMachine.fix_errors(query.df)

    # |> IO.inspect(label: "Fixed DF")

    updated_query = %{query | df: fixed_df, errors: []}
    IO.inspect(updated_query, label: "UPDATED QUERY")
    TransformMachine.emit_results(updated_query, pid)
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

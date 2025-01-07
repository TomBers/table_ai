defmodule TableAi.DataFix.FixErrors do
  alias TableAi.DataFix.AutoFixer
  alias TableAi.NlpExtract.TransformMachine

  @use_test_data Application.compile_env(:table_ai, :use_test_data)

  def error_fix(query) do
    if @use_test_data do
      AutoFixer.error_correct(query.errors)
    else
      AutoFixer.run_fixer(query.errors)
    end
  end

  # def fix_errors(query, pid) do
  #   fixes =
  #     if @use_test_data do
  #       AutoFixer.example_fixer(query.errors)
  #     else
  #       AutoFixer.run_fixer(query.errors)
  #     end

  #   IO.inspect(fixes, label: "Fixes")

  #   # AutoFixer.run_fixer(query.errors)
  #   [_ | fixed_df] =
  #     fixes
  #     |> TransformMachine.fix_errors(query.df)

  #   # |> IO.inspect(label: "Fixed DF")

  #   updated_query = %{query | df: fixed_df, errors: []}
  #   IO.inspect(updated_query, label: "UPDATED QUERY")
  #   TransformMachine.emit_results(updated_query, pid)
  # end

  def get_errors(res, df) do
    range_filter =
      Enum.find(res, fn step ->
        step["method"] == "filter_row_by_range" || step["method"] == "limit"
      end)

    TransformMachine.get_errors(df, range_filter["column_index"], range_filter["column_type"])
    |> Enum.to_list()
  end
end

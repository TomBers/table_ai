defmodule TableAi.DataFix.AutoFixer do
  def run_fixer(errors) do
    # Construct Prompt from the error data
    errors
    |> Enum.map(&IO.inspect(&1))
  end
end

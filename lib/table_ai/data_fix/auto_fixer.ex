defmodule TableAi.DataFix.AutoFixer do
  def run_fixer(errors) do
    # Construct Prompt from the error data
    prompt = "The errors :" <> Jason.encode!(errors)
    instructions = TableAi.DataFix.SystemInstructions.fix_errors()

    # Send the prompt to the LLM
    {:ok, fixed_errors} = TableAi.NlpExtract.TransformSteps.get(prompt, instructions)
    fixed_errors
  end

  def example_fixer(_errors) do
    [
      %{"column_index" => 10, "fixed_data" => "2022-03-25", "row_index" => 10},
      %{"column_index" => 10, "fixed_data" => "2022-01-17", "row_index" => 14}
    ]
  end
end

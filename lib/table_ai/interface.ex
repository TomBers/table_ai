defmodule TableAi.Interface do
  alias TableAi.NlpExtract.{TransformMachine, TransformSteps, DataLoader, SystemInstruction}
  alias TableAi.Structs.NLPQuery
  alias TableAi.LlmInterface

  @use_test_data Application.compile_env(:table_ai, :use_test_data)

  def gen_rows(query, pid) do
    # 1_031_289
    imdb_length = 2
    df = DataLoader.file(query.file_path, imdb_length)

    # This is just grabbing the headers from the CSV
    columns = Enum.take(df, 1) |> Enum.at(0)
    # First row seems to make the results worse
    # first_row = Enum.take(df, 2) |> Enum.at(1) |> Enum.join(", ")

    prompt =
      "I have a spreadsheet with columns [#{columns |> Enum.join(", ")}] and the question ```#{query.user_query}```."

    IO.inspect(prompt, label: "Prompt")

    steps =
      if @use_test_data do
        OpenaiExtract.run()
        # TransformSteps.example_steps(query.file_name)
      else
        instructions = SystemInstruction.get()
        {:ok, steps} = LlmInterface.get(prompt, instructions)
        steps
      end

    IO.inspect(steps, label: "Steps")

    query = %{
      query
      | df: df,
        file_path: query.file_path,
        headers: TransformSteps.get_headers(steps, columns),
        steps: steps,
        errors: []
    }

    TransformMachine.emit_results(query, pid)

    query
  end
end

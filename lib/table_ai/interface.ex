defmodule TableAi.Interface do
  alias TableAi.NlpExtract.{TransformMachine, TransformSteps, DataLoader, SystemInstruction}

  def gen_rows(file_path, query, pid) do
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
    # IO.inspect(res)
    # TransformMachine.return_results(res, df, 20)
    TransformMachine.emit_results(res, df, pid)
    {TransformSteps.get_headers(res, columns), []}
  end
end

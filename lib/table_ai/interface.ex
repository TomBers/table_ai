defmodule TableAi.Interface do
  alias TableAi.NlpExtract.TransformMachine
  alias TableAi.NlpExtract.SystemInstruction
  alias TableAi.NlpExtract.DataLoader
  alias TableAi.NlpExtract.TransformSteps

  def gen_rows(file_path, query, pid) do
    df = DataLoader.file(file_path)

    # ------------
    columns = Enum.take(df, 1) |> Enum.at(0) |> Enum.join(", ")
    prompt = "I have a spreadsheet with columns [#{columns}] and the question #{query}."
    instructions = SystemInstruction.get()
    {:ok, res} = TransformSteps.get(prompt, instructions)
    # ------------

    # FOR testing
    # res = TransformSteps.example_steps()
    # IO.inspect(res)
    # TransformMachine.return_results(res, df, 20)
    TransformMachine.emit_results(res, df, pid)
    []
  end
end

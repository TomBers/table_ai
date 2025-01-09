defmodule TableAi.Interface do
  alias TableAi.NlpExtract.{TransformMachine, TransformSteps, DataLoader, SystemInstruction}
  alias TableAi.Structs.NLPQuery
  # alias TableAi.LlmInterface
  alias TableAi.{OpenaiInterface, OpenaiExtract}

  require Logger

  @use_test_data Application.compile_env(:table_ai, :use_test_data)

  def gen_rows(query, pid) do
    # 1_031_289
    sample_size = 100_000
    df = DataLoader.file(query.file_path, sample_size)

    # This is just grabbing the headers from the CSV
    columns = Enum.take(df, 1) |> Enum.at(0)
    # First 10 rows of the CSV
    data = Enum.take(df, 10) |> to_json_data()

    {:ok, ennumerations} =
      Enum.take(df, sample_size)
      |> TableAi.NlpExtract.EnumDetector.detect_likely_enums(
        sample_size: sample_size,
        threshold: 80,
        case_sensitive: false
      )
      |> IO.inspect(label: "Detected enums")

    prompt =
      "I have a csv with columns [#{columns |> Enum.join(", ")}], with these enummerations #{Jason.encode!(ennumerations)}. This is the first 10 columns #{data}.  Use the columns and example data to answer the question: #{query.user_query}"

    Logger.info("Prompt: #{prompt}")

    steps =
      if @use_test_data do
        OpenaiExtract.run()
        # TransformSteps.example_steps(query.file_name)
      else
        # TODO - do some real world testing!!
        OpenaiInterface.run(prompt)
        |> OpenaiExtract.extract_steps_from_response()

        # instructions = SystemInstruction.get()
        # {:ok, steps} = LlmInterface.get(prompt, instructions)
        # steps
      end

    Logger.info("Steps: #{inspect(steps)}")

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

  def to_json_data(data) do
    [headers | rows] = data

    rows
    |> Enum.map(fn row ->
      headers
      |> Enum.zip(row)
      |> Enum.into(%{})
    end)
    |> Jason.encode!()
  end
end

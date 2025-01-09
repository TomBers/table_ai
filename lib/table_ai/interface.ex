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

    ennumerations =
      Enum.take(df, sample_size)
      |> detect_likely_enums(sample_size)
      |> Jason.encode!()

    # |> IO.inspect(label: "Detected enums")

    prompt =
      "I have a csv with columns [#{columns |> Enum.join(", ")}], with these enummerations #{ennumerations}. This is the first 10 columns #{data}.  Use the columns and example data to answer the question: #{query.user_query}"

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

  def detect_likely_enums(data, sample_size \\ 100, threshold \\ 10) do
    [headers | rows] = data
    sample_rows = Enum.take(rows, sample_size)

    headers
    |> Enum.with_index()
    |> Enum.map(fn {header, index} ->
      values =
        sample_rows
        |> Enum.map(&Enum.at(&1, index))
        |> Enum.reject(&(&1 == ""))

      enum_vals =
        values
        |> Enum.flat_map(fn value ->
          if String.contains?(value, ","),
            do: String.split(value, ",", trim: true),
            else: [value]
        end)
        |> MapSet.new()

      {header, enum_vals}
    end)
    |> Enum.into(%{})
    # If unique values are less than threshold % of sample size, consider it an enum
    |> Enum.reject(fn {_, enum_vals} -> MapSet.size(enum_vals) > threshold end)
    |> Enum.map(fn {header, enum_vals} -> %{header => MapSet.to_list(enum_vals)} end)
  end
end

defmodule TableAi.Interface do
  alias TableAi.NlpExtract.{
    TransformMachine,
    TransformSteps,
    DataLoader,
    EnumDetector
  }

  alias TableAi.{OpenaiInterface, OpenaiExtract}

  require Logger

  # TODO set the sample size relatd to number of rows
  @sample_size 100_000
  # This is currently hardcoded from the IMDB dataset - make a fraction of sample_size
  @threshold 30

  @use_test_data Application.compile_env(:table_ai, :use_test_data)

  def gen_rows(query, pid) do
    df = DataLoader.file(query.file_path, @sample_size)

    # This is just grabbing the headers from the CSV
    columns = Enum.take(df, 1) |> Enum.at(0)
    # First 10 rows of the CSV
    data = Enum.take(df, 10) |> to_json_data()

    {:ok, ennumerations} =
      Enum.take(df, @sample_size)
      |> EnumDetector.detect_likely_enums(
        sample_size: @sample_size,
        threshold: @threshold,
        case_sensitive: true
      )

    # |> IO.inspect(label: "Detected enums")

    prompt =
      "I have a csv with columns [#{columns |> Enum.join(", ")}], with these enummerations #{Jason.encode!(ennumerations)}. This is the first 10 columns #{data}.  Use the columns and example data to answer the question: #{query.user_query}"

    Logger.info("Query: #{query.user_query}")

    steps =
      if @use_test_data do
        OpenaiExtract.example_steps()
      else
        OpenaiInterface.run(prompt)
        |> OpenaiExtract.extract_steps_from_response()
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

    spawn(fn -> TransformMachine.emit_results(query, pid) end)

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

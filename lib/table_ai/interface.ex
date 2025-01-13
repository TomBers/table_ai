defmodule TableAi.Interface do
  alias TableAi.NlpExtract.{
    TransformMachine,
    DataLoader,
    EnumDetector
  }

  alias TableAi.{OpenaiInterface, OpenaiExtract}

  require Logger

  # This is currently hardcoded from the IMDB dataset - make a fraction of sample_size
  @threshold 30

  @use_test_data Application.compile_env(:table_ai, :use_test_data)

  def gen_rows(query, pid) do
    line_count = File.stream!(query.file_path, [], :line) |> Enum.count()
    IO.inspect(line_count, label: "LineCount")

    one_percent = div(line_count, 25)
    sample_size = max(one_percent, 10)
    IO.inspect(sample_size, label: "Sample Size")

    df = DataLoader.file(query.file_path, sample_size)

    # This is just grabbing the headers from the CSV
    columns = Enum.take(df, 1) |> Enum.at(0)
    # First 10 rows of the CSV
    data = Enum.take(df, 10) |> to_json_data()

    {:ok, ennumerations} =
      Enum.take(df, sample_size)
      |> EnumDetector.detect_likely_enums(
        sample_size: sample_size,
        threshold: @threshold,
        case_sensitive: true
      )
      |> IO.inspect(label: "Detected enums")

    prompt =
      "I have a csv with columns [#{columns |> Enum.join(", ")}], with these enummerations #{Jason.encode!(ennumerations)}. This is the first 10 columns #{data}.  Use the columns and example data to answer the question: #{query.user_query}"

    IO.inspect(prompt)
    Logger.info("Query: #{query.user_query}")

    steps =
      if @use_test_data do
        OpenaiExtract.example_steps(query.file_name)
      else
        OpenaiInterface.run(prompt)
        |> OpenaiExtract.extract_steps_from_response()
      end

    Logger.info("Steps: #{inspect(steps)}")

    query = %{
      query
      | df: df,
        file_path: query.file_path,
        headers: get_headers(steps, columns),
        steps: steps,
        errors: []
    }

    spawn(fn -> TransformMachine.emit_results(query, pid) end)

    query
  end

  defp to_json_data(data) do
    [headers | rows] = data

    rows
    |> Enum.map(fn row ->
      headers
      |> Enum.zip(row)
      |> Enum.into(%{})
    end)
    |> Jason.encode!()
  end

  defp get_headers(res, columns) do
    cols =
      res
      |> Enum.find(fn x -> x["method"] == "filter_column" end)

    case cols do
      nil ->
        if is_list(columns) do
          columns
        else
          columns |> String.split(",")
        end

      _ ->
        cols
        |> Map.get("columns")
        |> Enum.map(fn x -> Enum.at(columns, x) end)
    end
  end
end

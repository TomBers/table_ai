defmodule TableAi.FlowProcessing.FlowCsvTest do
  use ExUnit.Case, async: true

  alias Erl2exVendored.Results
  alias TableAi.FlowProcessing.FlowCsv

  describe "TableAi.FlowProcessing.FlowCsv.process_file/2" do
    test "it applies transformations on a file" do
      steps = [
        %{
          "column_index" => 6,
          "column_type" => "int",
          "from" => 1960,
          "method" => "filter_row_by_range",
          "to" => 1979
        },
        %{
          "column_index" => 4,
          "column_type" => "float",
          "from" => 7,
          "method" => "filter_row_by_range",
          "to" => nil
        },
        %{"filters" => ["London"], "method" => "filter_row", "row_index" => 1}
      ]

      file_path = "priv/static/uploads/imdb"

      result = FlowCsv.process_file(file_path, steps) |> IO.inspect(label: "Results")

      assert result.errors == [], "Expected no errors, got: #{inspect(result.errors)}"
      assert length(result.data) == 12, "Expected 12 row, got: #{inspect(result.data)}"
    end
  end
end

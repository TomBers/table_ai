defmodule TableAi.NlpExtract.TransformSteps do
  def example_steps do
    TableAi.NlpExtract.PastSteps.limit()
    # TableAi.NlpExtract.PastSteps.date_range()
  end

  def get_headers(res, columns) do
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

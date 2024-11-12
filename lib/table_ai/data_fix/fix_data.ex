defmodule TableAi.DataFix.FixData do
  def run do
    tst()
    |> Enum.map(&Enum.flat_map(&1.data, fn date -> extract_date(date, &1.regex) end))
  end

  def extract_date(string, regex_str) do
    IO.inspect({string, regex_str})
    {:ok, regex} = Regex.compile(regex_str)

    Regex.scan(regex, string) |> IO.inspect()

    # case Regex.scan(regex, string) |> IO.inspect() do
    #   [_, year, month, day] ->
    #     {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
    #     |> Date.from_erl()

    #   _ ->
    #     {:error, "No valid date found in string"}
    # end
  end

  def tst do
    [
      %{
        method: "fix_date",
        data: ["2020-02-25 - on a thursday", "2020-02-25"],
        regex: """
        ~r/^(\d{4}-\d{2}-\d{2})/
        """
      }
    ]
  end
end

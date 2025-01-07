defmodule TableAi.NlpExtract.DataLoader do
  def file(path, take \\ 10_000) do
    # take = 2_000_000

    # IO.inspect(path, label: "Path")

    File.stream!(path, [], :line)
    |> CSV.decode!()
    |> Stream.take(take)
  end
end

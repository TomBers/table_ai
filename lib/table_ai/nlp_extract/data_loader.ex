defmodule TableAi.NlpExtract.DataLoader do
  def file(path) do
    # take = 2_000_000
    # take = 10_000
    take = 100

    File.stream!(path, [], :line)
    |> CSV.decode!()
    |> Stream.take(take)
  end
end

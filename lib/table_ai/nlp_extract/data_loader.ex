defmodule TableAi.NlpExtract.DataLoader do
  def file(path, take \\ 10_000) do
    File.stream!(path, [], :line)
    |> CSV.decode!()
    |> Stream.take(take)
  end
end

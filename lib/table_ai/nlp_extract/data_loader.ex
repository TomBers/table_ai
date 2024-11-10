defmodule TableAi.NlpExtract.DataLoader do
  # def file do
  #   # take = 2_000_000
  #   take = 5000
  #   path = "customers-2000000.csv"

  #   file_stream(path, take)
  # end

  def file(path) do
    take = 1_00_000

    File.stream!(path, [], :line)
    |> CSV.decode!()
    |> Stream.take(take)
  end
end

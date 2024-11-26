defmodule TableAiWeb.FileLive do
  use TableAiWeb, :live_view
  import TableAiWeb.CoreComponents

  alias TableAi.NlpExtract.DataLoader

  def mount(params, _session, socket) do
    path = Map.get(params, "path")

    file_path =
      Path.join(Application.app_dir(:table_ai, "priv/static/uploads"), Path.basename(path))

    df = DataLoader.file(file_path)
    headers = Enum.take(df, 1) |> Enum.at(0)
    [_ | rows] = df |> Enum.to_list()

    {:ok, socket |> assign(headers: headers, rows: rows)}
  end
end

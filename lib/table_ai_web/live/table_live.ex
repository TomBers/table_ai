defmodule TableAiWeb.TableLive do
  alias Ecto.UUID
  use TableAiWeb, :live_view
  import TableAiWeb.CoreComponents

  def mount(params, _session, socket) do
    IO.inspect(params)

    path =
      case Map.get(params, "path") do
        nil ->
          "customers-2000000.csv"

        path ->
          Path.join(Application.app_dir(:table_ai, "priv/static/uploads"), Path.basename(path))
      end

    {:ok,
     socket
     |> assign(form: %{}, path: path, rows: [], query_id: UUID.generate())}
  end

  def handle_event("save", %{"query" => query}, socket) do
    pid = self()
    TableAi.Interface.gen_rows(socket.assigns.path, query, pid)

    {:noreply,
     socket
     |> assign(query_id: UUID.generate(), rows: [])}
  end

  def handle_event("edit", _params, socket) do
    {:noreply, socket |> assign(rows: [])}
  end

  def handle_info({:rows, rows}, socket) do
    IO.inspect(DateTime.utc_now(), label: "HANDLE INFO")
    {:noreply, socket |> assign(rows: socket.assigns.rows ++ rows)}
  end
end

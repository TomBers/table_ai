defmodule TableAiWeb.TableLive do
  alias Ecto.UUID
  use TableAiWeb, :live_view
  import TableAiWeb.CoreComponents

  def mount(params, _session, socket) do
    path =
      case Map.get(params, "path") do
        nil ->
          "customers-2000000.csv"

        path ->
          Path.join(Application.app_dir(:table_ai, "priv/static/uploads"), Path.basename(path))
      end

    nlp_query = %TableAi.Structs.NLPQuery{}

    {:ok,
     socket
     |> assign(
       form: %{},
       path: path,
       rows: [],
       nlp_query: nlp_query,
       query_id: UUID.generate()
     )}
  end

  def handle_event("save", %{"query" => query}, socket) do
    IO.inspect(query, label: "User Query")
    pid = self()

    nlp_query =
      TableAi.Interface.gen_rows(socket.assigns.path, query, pid)
      |> IO.inspect(label: "NLP Query")

    {:noreply,
     socket
     |> assign(query_id: UUID.generate(), nlp_query: nlp_query)}
  end

  def handle_event("edit", _params, socket) do
    {:noreply, socket |> assign(rows: [])}
  end

  def handle_event("skip", _params, socket) do
    pid = self()
    TableAi.Interface.emit_results(socket.assigns.nlp_query, pid)
    {:noreply, socket |> assign(nlp_query: %{socket.assigns.nlp_query | errors: []})}
  end

  def handle_event("autofix", _params, socket) do
    pid = self()
    TableAi.Interface.fix_errors(socket.assigns.nlp_query, pid)

    {:noreply, socket |> assign(nlp_query: %{socket.assigns.nlp_query | errors: []})}
  end

  def handle_info({:rows, rows}, socket) do
    IO.inspect(DateTime.utc_now(), label: "HANDLE INFO")
    IO.inspect(rows, label: "ROWS")
    {:noreply, socket |> assign(rows: socket.assigns.rows ++ rows)}
  end

  def row_string(rows) do
    "Rows: #{Enum.count(rows)}"
  end
end

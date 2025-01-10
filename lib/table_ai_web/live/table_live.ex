defmodule TableAiWeb.TableLive do
  alias Ecto.UUID
  use TableAiWeb, :live_view
  import TableAiWeb.CoreComponents

  require Logger

  def mount(params, _session, socket) do
    file_name = Map.get(params, "path", "customers-2000000.csv")

    path =
      Path.join(Application.app_dir(:table_ai, "priv/static/uploads"), Path.basename(file_name))

    nlp_query = %TableAi.Structs.NLPQuery{file_path: path, file_name: file_name}

    {:ok,
     socket
     |> assign(
       form: %{},
       rows: [],
       nlp_query: nlp_query,
       query_id: UUID.generate(),
       loading: false
     )}
  end

  def handle_event("save", %{"query" => user_query}, socket) do
    pid = self()

    q = TableAi.Structs.NLPQuery.reset_query(socket.assigns.nlp_query, user_query)

    nlp_query =
      TableAi.Interface.gen_rows(q, pid)

    {:noreply,
     socket
     |> assign(nlp_query: nlp_query, rows: [], errors: [], loading: true)}
  end

  def handle_event("edit", _params, socket) do
    {:noreply, socket |> assign(rows: [], loading: false)}
  end

  def handle_event("autofix", _params, socket) do
    pid = self()
    error_fixes = TableAi.DataFix.FixErrors.error_fix(socket.assigns.nlp_query)
    # IO.inspect(error_fixes, label: "Error Fixes")
    TableAi.NlpExtract.TransformMachine.emit_results(socket.assigns.nlp_query, pid, error_fixes)

    # query_id: UUID.generate()
    {:noreply, socket}
  end

  def handle_info({:rows, res}, socket) do
    # IO.inspect(DateTime.utc_now(), label: "HANDLE INFO")
    rows = Map.get(res, :data, [])
    errors = Map.get(res, :errors, [])

    # IO.inspect(errors, label: "Errors")
    Logger.info("Rows: #{inspect(rows)}")

    {:noreply,
     socket
     |> assign(rows: rows, nlp_query: socket.assigns.nlp_query, errors: errors, loading: false)}
  end
end

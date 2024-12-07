defmodule TableAiWeb.FileUploadLive do
  use TableAiWeb, :live_view

  def mount(_params, _session, socket) do
    # 100MB
    max_file_size = 100_000_000

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.csv), max_entries: 1, max_file_size: max_file_size)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    IO.inspect("Saving file")

    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest =
          Path.join(Application.app_dir(:table_ai, "priv/static/uploads"), Path.basename(path))

        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    path = hd(uploaded_files)
    {:noreply, socket |> push_navigate(to: "/talk" <> path)}
    # {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end
end

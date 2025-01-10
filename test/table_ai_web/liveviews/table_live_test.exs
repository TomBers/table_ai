defmodule TableAiWeb.TableLiveTest do
  use TableAiWeb.ConnCase
  import Phoenix.LiveViewTest

  @path "/talk/uploads/imdb"
  @timeout 2000

  test "processes query and displays results in table", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/talk/uploads/imdb")

    # Submit the query
    view
    |> form("form", %{query: "show me all ages above 30"})
    |> render_submit()

    # Wait for processing to complete
    # Adjust timing based on your processing time
    Process.sleep(@timeout)

    # Get the rendered content
    rows = render(view) |> find_rows()

    # Assert specific values in the table
    # Replace with actual expected values
    assert rows != []
    assert length(rows) == 11
  end

  defp find_rows(html) do
    Floki.find(html, "tr")
  end
end

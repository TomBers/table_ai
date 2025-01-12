defmodule TableAiWeb.TableLiveTest do
  use TableAiWeb.ConnCase
  import Phoenix.LiveViewTest

  @path "/talk/uploads/imdb"
  @timeout 2000

  test "processes query and displays results in table", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/talk/uploads/imdb")

    rows =
      get_rendered_rows(
        view,
        "Get me the top 10 horror movies from the 1980s where the number of votes is greater than 1000"
      )

    assert length(rows) == 10

    IO.inspect(rows, label: "Rows")

    first_row = [
      "1",
      "tt0084787",
      "The Thing",
      "movie",
      "Horror, Mystery, Sci-Fi",
      "8.2",
      "484311",
      "1982"
    ]

    assert hd(rows) == first_row
  end

  def get_rendered_rows(view, query) do
    view
    |> form("form", %{query: query})
    |> render_submit()

    # Wait for processing to complete
    # Adjust timing based on your processing time
    Process.sleep(@timeout)

    # Get the rendered content
    rows = render(view) |> find_rows()

    [_ | vals] = rows
    vals |> Enum.map(fn row -> extract_row_vals(row) end)
  end

  def extract_row_vals(row) do
    Floki.find(row, "td")
    |> Enum.map(&Floki.text/1)
    |> Enum.map(&String.trim/1)
  end

  defp find_rows(html) do
    Floki.find(html, "tr")
  end
end

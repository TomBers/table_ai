defmodule TableAiWeb.PageControllerTest do
  use TableAiWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200)
  end
end

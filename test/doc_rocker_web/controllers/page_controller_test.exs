defmodule DocRockerWeb.HomeLiveTest do
  use DocRockerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Predefined Picks"
    assert html =~ "Ask a question about documented knowledge..."
  end
end

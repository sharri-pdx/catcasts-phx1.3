defmodule CatcastsPhx13Web.NavigationTest do
  use CatcastsPhx13Web.ConnCase, async: true

  test "verifies navbar is displayed", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<div class=\"top-bar\" id=\"my-menu\">"
  end
end

defmodule KriteWeb.ErrorJSONTest do
  use KriteWeb.ConnCase, async: true

  test "renders 404" do
    assert KriteWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert KriteWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

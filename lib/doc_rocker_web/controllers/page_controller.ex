defmodule DocRockerWeb.PageController do
  use DocRockerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

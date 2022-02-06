defmodule CafeWeb.PageController do
  use CafeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

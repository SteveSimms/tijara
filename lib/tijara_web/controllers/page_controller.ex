defmodule TijaraWeb.PageController do
  use TijaraWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

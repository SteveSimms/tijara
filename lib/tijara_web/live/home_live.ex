defmodule TijaraWeb.HomeLive do
  use TijaraWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Welcome to Tijara</h1>
    """
  end
end

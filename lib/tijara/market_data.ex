defmodule Tijara.MarketData do
  @moduledoc """
  Context for retrieving market data.
  """

  alias Tijara.MarketData.Client

  def get_quote(symbol) do
    Client.get_quote(symbol)
  end
end

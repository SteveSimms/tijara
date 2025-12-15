defmodule Tijara.MarketData.Client do
  @moduledoc """
  Client for interacting with the Finnhub API.
  """

  @base_url "https://finnhub.io/api/v1"

  def get_quote(symbol) when is_binary(symbol) do
    api_key = Application.get_env(:tijara, :finnhub_api_key)

    if is_nil(api_key) do
      {:error, :missing_api_key}
    else
      Req.get!("#{@base_url}/quote", params: [symbol: symbol, token: api_key])
      |> handle_response()
    end
  end

  defp handle_response(%Req.Response{status: 200, body: body}) do
    # Finnhub quote response:
    # {
    #   "c": 261.74, // Current price
    #   "h": 263.31, // High
    #   "l": 260.68, // Low
    #   "o": 261.07, // Open
    #   "pc": 259.45, // Previous close
    #   "t": 1582641000 // Timestamp
    # }
    {:ok, body}
  end

  defp handle_response(%Req.Response{status: status}) do
    {:error, "API returned status #{status}"}
  end

  defp handle_response(error), do: {:error, error}
end

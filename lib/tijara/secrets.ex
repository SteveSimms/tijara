defmodule Tijara.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Tijara.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:tijara, :token_signing_secret)
  end
end

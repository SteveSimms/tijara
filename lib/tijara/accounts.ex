defmodule Tijara.Accounts do
  use Ash.Domain, otp_app: :tijara, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Tijara.Accounts.Token
    resource Tijara.Accounts.User
  end
end

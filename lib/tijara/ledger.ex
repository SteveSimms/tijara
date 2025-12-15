defmodule Tijara.Ledger do
  use Ash.Domain,
    otp_app: :tijara

  resources do
    resource Tijara.Ledger.Account
    resource Tijara.Ledger.Balance
    resource Tijara.Ledger.Transfer
  end
end

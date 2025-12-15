defmodule Tijara.Journal do
  use Ash.Domain

  resources do
    resource Tijara.Journal.Entry
  end
end

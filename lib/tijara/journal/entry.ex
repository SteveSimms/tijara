defmodule Tijara.Journal.Entry do
  use Ash.Resource,
    domain: Tijara.Journal,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "journal_entries"
    repo Tijara.Repo
  end

  code_interface do
    define :read, action: :read
    define :create, action: :create
    define :close_position, action: :close_position
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:pair, :type, :entry_price, :exit_price, :size, :strategy, :notes, :date, :status]
    end

    update :update do
      accept [:pair, :type, :entry_price, :exit_price, :size, :strategy, :notes, :date, :status]
    end

    update :close_position do
      accept [:exit_price, :notes]
      # Logic to calculate pnl could go here or be a calculation
      change set_attribute(:status, :closed)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :pair, :string do
      allow_nil? false
    end

    attribute :type, :atom do
      constraints one_of: [:long, :short]
      allow_nil? false
    end

    # Using decimal for prices and size for precision
    attribute :entry_price, :decimal do
      allow_nil? false
    end

    attribute :exit_price, :decimal

    attribute :size, :decimal do
      allow_nil? false
      default 1.0
    end

    attribute :strategy, :string

    attribute :notes, :string

    attribute :date, :date do
      allow_nil? false
      default &Date.utc_today/0
    end

    attribute :status, :atom do
      constraints one_of: [:open, :closed, :pending]
      default :open
      allow_nil? false
    end

    timestamps()
  end

  # Calculations for PNL could be added here later
end

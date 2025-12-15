defmodule TijaraWeb.JournalLive do
  use TijaraWeb, :live_view

  def mount(_params, _session, socket) do
    # Fetch real data for ticker
    quotes = fetch_quotes(["AAPL", "GOOGL", "EUR/USD", "GBP/JPY", "XAU/USD"])

    # Load Real Entries
    entries = Tijara.Journal.Entry.read!()

    socket =
      socket
      # Placeholder until Account logic
      |> assign(:balance, Money.new(:USD, "12450.00"))
      # Placeholder
      |> assign(:pnl, Money.new(:USD, "850.50"))
      # Placeholder
      |> assign(:win_rate, 0.68)
      |> assign(:quotes, quotes)
      |> stream(:journal_entries, entries)
      |> assign(:form, to_form(AshPhoenix.Form.for_create(Tijara.Journal.Entry, :create)))
      |> assign(:show_modal, false)

    {:ok, socket}
  end

  def handle_event("save", %{"form" => entry_params}, socket) do
    # TODO: refactor this to match the best practices of AshPhoenix per the Ash Framework Book
    form = AshPhoenix.Form.for_create(Tijara.Journal.Entry, :create)

    case AshPhoenix.Form.submit(form, params: entry_params) do
      {:ok, entry} ->
        {:noreply,
         socket
         # Prepend
         |> stream_insert(:journal_entries, entry, at: 0)
         |> assign(:show_modal, false)
         # Reset form
         |> assign(:form, to_form(AshPhoenix.Form.for_create(Tijara.Journal.Entry, :create)))
         |> put_flash(:info, "Trade logged successfully.")}

      {:error, form} ->
        {:noreply, assign(socket, :form, to_form(form))}
    end
  end

  def handle_event("toggle_modal", _, socket) do
    {:noreply, update(socket, :show_modal, &(!&1))}
  end

  # Helper Functions
  defp calculate_pnl(entry) do
    # Dynamic calculation if open and quote exists, else static profit calculation
    # For now, simplistic
    if entry.status == :closed and entry.exit_price do
      diff = Decimal.sub(entry.exit_price, entry.entry_price)
      multiplier = if entry.type == :short, do: -1, else: 1
      # Assuming 1 lot = 100k units (standard forex) or 1 unit (stock) - simplification
      # We'll just use a raw multiplier of 10 for demo visualization
      pnl = Decimal.mult(diff, Decimal.new(10)) |> Decimal.mult(Decimal.new(multiplier))
      Money.new(:USD, Decimal.round(pnl, 2))
    else
      Money.new(:USD, 0)
    end
  end

  defp fetch_quotes(symbols) do
    Enum.reduce(symbols, %{}, fn symbol, acc ->
      case Tijara.MarketData.get_quote(symbol) do
        {:ok, data} -> Map.put(acc, symbol, data)
        _ -> acc
      end
    end)
  end

  defp formatted_win_rate(rate), do: "#{round(rate * 100)}%"

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100/50">
      <div class="px-4 py-6 max-w-7xl mx-auto space-y-8">
        <!-- Header / Ticker -->
        <div class="flex flex-col md:flex-row justify-between items-center gap-6 pb-6 border-b border-white/5">
          <div>
            <h1 class="text-2xl font-light text-white/90 tracking-widest uppercase">
              Trading <span class="text-primary font-normal">Journal</span>
            </h1>
            <p class="text-xs text-white/40 mt-1 font-mono">
              Market Clarity & Edge Analysis
            </p>
          </div>
          
    <!-- Mini Ticker -->
          <div class="flex gap-4 overflow-x-auto pb-2 md:pb-0">
            <%= for {symbol, data} <- @quotes do %>
              <div class="flex flex-col items-center px-4 py-2 rounded bg-base-100/30 border border-white/5 backdrop-blur-sm min-w-[80px]">
                <span class="text-[10px] text-white/50 font-mono tracking-widest uppercase">
                  {symbol}
                </span>
                <span class={"text-sm font-light " <> if(data["c"] >= data["pc"], do: "text-success", else: "text-error")}>
                  {data["c"]}
                </span>
              </div>
            <% end %>
          </div>
        </div>
        
    <!-- Stats Overview -->
        <section class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <.stat_card title="Account Balance" value={@balance} icon="hero-banknotes" />
          <.stat_card title="Monthly PNL" value={@pnl} trend={:up} icon="hero-chart-bar" />
          <.stat_card title="Win Rate" value={formatted_win_rate(@win_rate)} icon="hero-trophy" />
        </section>
        <!-- Journal Entries List -->
        <section class="space-y-6">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-light tracking-wide text-white/80 uppercase">
              Recent Trades
            </h2>
            <button
              phx-click="toggle_modal"
              class="btn btn-sm btn-primary btn-outline gap-2 uppercase text-xs tracking-widest"
            >
              <.icon name="hero-plus" class="w-4 h-4" /> Log Trade
            </button>
          </div>

          <div id="journal_entries" phx-update="stream" class="space-y-4">
            <div
              :for={{dom_id, entry} <- @streams.journal_entries}
              id={dom_id}
              class="group relative overflow-hidden rounded-xl bg-base-100/30 border border-white/5 p-5 hover:bg-base-100/50 transition-all duration-300"
            >
              <!-- Hover Gradient -->
              <div class="absolute inset-0 bg-gradient-to-r from-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              </div>

              <div class="relative grid grid-cols-1 md:grid-cols-12 gap-4 items-center">
                <!-- Pair & Type -->
                <div class="md:col-span-3 flex items-center gap-3">
                  <div class={"w-1 h-12 rounded-full " <> if(entry.type == :long, do: "bg-success", else: "bg-error")}>
                  </div>
                  <div>
                    <div class="text-lg font-medium text-white/90">{entry.pair}</div>
                    <span class={[
                      "text-xs font-bold tracking-wider uppercase",
                      if(entry.type == :long, do: "text-success", else: "text-error")
                    ]}>
                      {Atom.to_string(entry.type)}
                    </span>
                  </div>
                </div>
                
    <!-- Strategy & Size (New Columns) -->
                <div class="md:col-span-3">
                  <div class="flex flex-col gap-1">
                    <span class="text-xs text-white/40 uppercase tracking-wider">Strategy</span>
                    <span class="badge badge-neutral badge-sm rounded-md text-xs font-mono">
                      {entry.strategy || "-"}
                    </span>
                  </div>
                </div>

                <div class="md:col-span-2">
                  <div class="flex flex-col gap-1">
                    <span class="text-xs text-white/40 uppercase tracking-wider">Size</span>
                    <span class="text-sm text-white/80 font-mono">{entry.size} Lots</span>
                  </div>
                </div>
                
    <!-- PNL & Status -->
                <div class="md:col-span-4 text-right">
                  <div class={
                    [
                      "text-lg font-bold font-mono",
                      # if(Money.positive?(entry.profit), do: "text-success", else: "text-error") # Need computed field
                      "text-white/80"
                    ]
                  }>
                    {calculate_pnl(entry)}
                  </div>
                  <div class="text-xs text-white/30 uppercase tracking-widest mt-1">
                    {entry.status}
                    <%= if entry.status == :open and entry.exit_price do %>
                      <span class="ml-1 text-[10px] text-primary">(Live)</span>
                    <% end %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </div>
      
    <!-- Simple Modal for New Entry -->
    <!-- Simple Modal for New Entry -->
      <%= if @show_modal do %>
        <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
          <!-- Backdrop -->
          <div
            class="absolute inset-0 bg-black/80 backdrop-blur-sm transition-opacity"
            phx-click="toggle_modal"
          >
          </div>
          
    <!-- Modal Content -->
          <div class="relative bg-base-100 border border-white/10 rounded-2xl w-full max-w-lg p-8 shadow-2xl overflow-hidden group">
            
    <!-- Glow Effect -->
            <div class="absolute -top-24 -right-24 w-48 h-48 bg-primary/20 rounded-full blur-3xl opacity-50 pointer-events-none">
            </div>

            <button
              phx-click="toggle_modal"
              class="absolute top-6 right-6 text-white/30 hover:text-white transition-colors"
            >
              <.icon name="hero-x-mark" class="w-6 h-6" />
            </button>

            <h3 class="text-xl font-light uppercase tracking-widest text-white/90 mb-8 flex items-center gap-3">
              <span class="w-1 h-6 bg-primary rounded-full"></span> Log New Trade
            </h3>

            <.form for={@form} phx-submit="save" class="space-y-6">
              <div class="grid grid-cols-2 gap-6">
                <div class="space-y-2">
                  <label class="text-xs text-white/50 uppercase tracking-wider font-medium ml-1">
                    Pair
                  </label>
                  <.input
                    field={@form[:pair]}
                    placeholder="e.g. EUR/USD"
                    class="w-full bg-base-200/50 border border-white/10 focus:border-primary/50 text-white rounded-lg px-4 py-3 text-sm placeholder:text-white/20 transition-all focus:ring-1 focus:ring-primary/50 focus:outline-none"
                  />
                </div>
                <div class="space-y-2">
                  <label class="text-xs text-white/50 uppercase tracking-wider font-medium ml-1">
                    Type
                  </label>
                  <.input
                    field={@form[:type]}
                    type="select"
                    options={[:long, :short]}
                    prompt="Select Direction"
                    class="w-full bg-base-200/50 border border-white/10 focus:border-primary/50 text-white rounded-lg px-4 py-3 text-sm transition-all focus:ring-1 focus:ring-primary/50 focus:outline-none appearance-none"
                  />
                </div>
              </div>

              <div class="grid grid-cols-2 gap-6">
                <div class="space-y-2">
                  <label class="text-xs text-white/50 uppercase tracking-wider font-medium ml-1">
                    Entry Price
                  </label>
                  <.input
                    field={@form[:entry_price]}
                    type="number"
                    step="any"
                    placeholder="0.00"
                    class="w-full bg-base-200/50 border border-white/10 focus:border-primary/50 text-white rounded-lg px-4 py-3 text-sm placeholder:text-white/20 transition-all focus:ring-1 focus:ring-primary/50 focus:outline-none"
                  />
                </div>
                <div class="space-y-2">
                  <label class="text-xs text-white/50 uppercase tracking-wider font-medium ml-1">
                    Size (Lots)
                  </label>
                  <.input
                    field={@form[:size]}
                    type="number"
                    step="any"
                    placeholder="1.0"
                    class="w-full bg-base-200/50 border border-white/10 focus:border-primary/50 text-white rounded-lg px-4 py-3 text-sm placeholder:text-white/20 transition-all focus:ring-1 focus:ring-primary/50 focus:outline-none"
                  />
                </div>
              </div>

              <div class="space-y-2">
                <label class="text-xs text-white/50 uppercase tracking-wider font-medium ml-1">
                  Strategy Tag
                </label>
                <.input
                  field={@form[:strategy]}
                  placeholder="e.g. Break & Retest, Scalp, Swing"
                  class="w-full bg-base-200/50 border border-white/10 focus:border-primary/50 text-white rounded-lg px-4 py-3 text-sm placeholder:text-white/20 transition-all focus:ring-1 focus:ring-primary/50 focus:outline-none"
                />
              </div>

              <div class="space-y-2">
                <label class="text-xs text-white/50 uppercase tracking-wider font-medium ml-1">
                  Notes
                </label>
                <.input
                  field={@form[:notes]}
                  type="textarea"
                  placeholder="Record your mindset and execution details..."
                  class="w-full bg-base-200/50 border border-white/10 focus:border-primary/50 text-white rounded-lg px-4 py-3 text-sm placeholder:text-white/20 transition-all focus:ring-1 focus:ring-primary/50 focus:outline-none min-h-[100px] resize-none"
                />
              </div>

              <div class="flex justify-end gap-3 pt-4 border-t border-white/5 mt-8">
                <button
                  type="button"
                  phx-click="toggle_modal"
                  class="px-6 py-2 rounded-lg text-sm text-white/50 hover:text-white hover:bg-white/5 transition-all"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  class="px-6 py-2 rounded-lg text-sm font-medium bg-primary text-primary-content hover:bg-primary-focus shadow-lg shadow-primary/20 transition-all hover:scale-105"
                >
                  Save Journal Entry
                </button>
              </div>
            </.form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <div class="relative overflow-hidden rounded-2xl bg-base-100/30 border border-white/5 p-6 backdrop-blur-sm group hover:bg-base-100/40 transition-all duration-300">
      <div class="absolute -right-6 -top-6 w-24 h-24 bg-gradient-to-br from-white/5 to-white/0 rounded-full blur-xl group-hover:bg-primary/10 transition-colors duration-500">
      </div>

      <div class="relative flex justify-between items-start">
        <div>
          <p class="text-sm font-medium text-white/40 uppercase tracking-widest">{@title}</p>
          <div class="mt-2 text-3xl font-light text-white/90 tracking-tight">{@value}</div>
        </div>
        <div class="p-2 rounded-lg bg-white/5 text-white/60 group-hover:text-primary group-hover:bg-primary/10 transition-all duration-300">
          <.icon name={@icon} class="w-6 h-6" />
        </div>
      </div>

      <%= if assigns[:trend] do %>
        <div class="mt-4 flex items-center gap-2 text-xs">
          <span class="text-success bg-success/10 px-1.5 py-0.5 rounded flex items-center gap-1">
            <.icon name="hero-arrow-trending-up" class="w-3 h-3" /> +12.5%
          </span>
          <span class="text-white/20">vs last month</span>
        </div>
      <% end %>
    </div>
    """
  end
end

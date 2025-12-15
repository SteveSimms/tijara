defmodule TijaraWeb.HomeLive do
  use TijaraWeb, :live_view

  def mount(_params, _session, socket) do
    # Mock Data for Prototype
    socket =
      socket
      |> assign(:balance, Money.new(:USD, "12450.00"))
      |> assign(:pnl, Money.new(:USD, "850.50"))
      |> assign(:win_rate, 0.68)
      |> assign(:journal_entries, [
        %{
          id: 1,
          pair: "EUR/USD",
          type: :long,
          entry: 1.0850,
          exit: 1.0920,
          profit: Money.new(:USD, "350.00"),
          date: ~D[2024-10-24],
          status: :closed,
          notes: "Clean break and retest of daily support."
        },
        %{
          id: 2,
          pair: "GBP/JPY",
          type: :short,
          entry: 184.50,
          exit: 183.80,
          profit: Money.new(:USD, "420.00"),
          date: ~D[2024-10-23],
          status: :closed,
          notes: "News play on CPI data. High volatility."
        },
        %{
          id: 3,
          pair: "XAU/USD",
          type: :long,
          entry: 1980.00,
          exit: nil,
          profit: Money.new(:USD, "80.50"),
          date: ~D[2024-10-25],
          status: :open,
          notes: "Holding for weekly target."
        }
      ])

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-16">
      <!-- Hero Section -->
      <section class="text-center space-y-4 pt-8">
        <h1 class="text-4xl sm:text-5xl font-thin tracking-[0.2em] text-white/90 uppercase drop-shadow-[0_0_15px_rgba(255,255,255,0.1)]">
          Market <span class="text-primary font-normal">Symphony</span>
        </h1>
        <p class="text-lg text-white/40 font-light tracking-wide max-w-2xl mx-auto">
          Compose your edge in the noise of the market.
        </p>
      </section>
      
    <!-- Stats Grid -->
      <section class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <.stat_card title="Account Balance" value={@balance} icon="hero-banknotes" />
        <.stat_card title="Monthly PNL" value={@pnl} trend={:up} icon="hero-chart-bar" />
        <.stat_card title="Win Rate" value={formatted_win_rate(@win_rate)} icon="hero-trophy" />
      </section>
      
    <!-- Journal & AI Section -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Recent Entries -->
        <section class="lg:col-span-2 space-y-6">
          <div class="flex items-center justify-between pb-2 border-b border-white/5">
            <h2 class="text-xl font-light tracking-widest text-white/80 uppercase">
              Recent Movements
            </h2>
            <button class="text-xs font-bold text-primary hover:text-primary-focus uppercase tracking-widest transition-colors">
              View All
            </button>
          </div>

          <div class="space-y-4">
            <div
              :for={entry <- @journal_entries}
              class="group relative overflow-hidden rounded-xl bg-base-100/30 border border-white/5 p-5 hover:bg-base-100/50 transition-all duration-300"
            >
              <div class="absolute inset-0 bg-gradient-to-r from-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              </div>

              <div class="relative flex items-center justify-between">
                <div>
                  <div class="flex items-center gap-3 mb-1">
                    <span class={[
                      "text-sm font-bold tracking-wider",
                      if(entry.type == :long, do: "text-success", else: "text-error")
                    ]}>
                      {String.upcase(Atom.to_string(entry.type))}
                    </span>
                    <span class="text-lg font-medium text-white/90">{entry.pair}</span>
                    <span class="text-xs text-white/30 font-mono">{entry.date}</span>
                  </div>
                  <p class="text-sm text-white/50">{entry.notes}</p>
                </div>

                <div class="text-right">
                  <div class={[
                    "text-lg font-bold font-mono",
                    if(Money.positive?(entry.profit), do: "text-success", else: "text-error")
                  ]}>
                    {entry.profit}
                  </div>
                  <div class="text-xs text-white/30 uppercase tracking-widest mt-1">
                    {entry.status}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
        
    <!-- AI Assistant Placeholder -->
        <section class="relative overflow-hidden rounded-2xl border border-white/10 bg-gradient-to-b from-base-100/50 to-base-100/20 p-6 flex flex-col justify-between min-h-[400px]">
          <div class="absolute top-0 right-0 p-4 opacity-20">
            <.icon name="hero-sparkles" class="w-24 h-24 text-primary" />
          </div>

          <div class="space-y-4 relative z-10">
            <h2 class="text-2xl font-light text-white/90">Insight Core</h2>
            <p class="text-sm text-white/50 leading-relaxed">
              Analyze your performance patterns. Ask about your recent drawdown or optimal entry times.
            </p>
          </div>

          <div class="space-y-3 relative z-10 mt-auto">
            <div class="bg-base-300/50 rounded-lg p-3 text-sm text-white/60 italic border-l-2 border-primary/50">
              "What is my win rate on EUR/USD on Tuesdays?"
            </div>
            <button class="btn btn-outline btn-primary w-full gap-2 group">
              <span>Initialize Chat</span>
              <.icon
                name="hero-arrow-right"
                class="w-4 h-4 group-hover:translate-x-1 transition-transform"
              />
            </button>
          </div>
        </section>
      </div>
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

  defp formatted_win_rate(rate) do
    "#{round(rate * 100)}%"
  end
end

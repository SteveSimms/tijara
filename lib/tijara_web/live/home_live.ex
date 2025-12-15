defmodule TijaraWeb.HomeLive do
  use TijaraWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-[80vh] flex flex-col items-center justify-center space-y-8 text-center px-4">
      <div class="space-y-4">
        <h1 class="text-5xl sm:text-7xl font-thin tracking-[0.2em] text-white/90 uppercase drop-shadow-[0_0_25px_rgba(255,255,255,0.1)]">
          Market <span class="text-primary font-normal">Symphony</span>
        </h1>
        <p class="text-xl text-white/40 font-light tracking-wide max-w-2xl mx-auto leading-relaxed">
          Compose your edge in the noise of the market.
        </p>
      </div>

      <div class="pt-8">
        <.link
          navigate={~p"/journal"}
          class="group relative inline-flex items-center gap-3 px-8 py-4 bg-primary/10 hover:bg-primary/20 border border-primary/30 rounded-full transition-all duration-300 backdrop-blur-md"
        >
          <span class="text-primary font-medium tracking-[0.15em] uppercase text-sm">
            Enter Journal
          </span>
          <.icon
            name="hero-arrow-right"
            class="w-4 h-4 text-primary group-hover:translate-x-1 transition-transform"
          />
          
    <!-- Glow efffect -->
          <div class="absolute inset-0 rounded-full bg-primary/20 blur-xl opacity-0 group-hover:opacity-100 transition-opacity duration-500">
          </div>
        </.link>
      </div>
    </div>
    """
  end
end

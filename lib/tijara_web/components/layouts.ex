defmodule TijaraWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use TijaraWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-300 bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-gray-800 via-base-300 to-black text-base-content antialiased selection:bg-primary selection:text-white overflow-x-hidden">
      <!-- Glassmorphic Navbar -->
      <header class="sticky top-0 z-50 w-full backdrop-blur-md bg-base-300/30 border-b border-white/5">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div class="flex items-center gap-4">
            <a href="/" class="flex items-center gap-2 group">
              <!-- Animated Logo Placeholder -->
              <div class="w-8 h-8 rounded-full bg-gradient-to-tr from-primary to-secondary opacity-80 group-hover:opacity-100 transition-opacity duration-300 blur-[1px]">
              </div>
              <span class="text-xl font-light tracking-widest uppercase text-white/90 group-hover:text-white transition-colors">
                Tijara
              </span>
            </a>
          </div>

          <nav class="flex items-center gap-6">
            <ul class="flex items-center gap-6 text-sm font-medium text-white/60">
              <li><a href="#" class="hover:text-white transition-colors duration-200">Journal</a></li>
              <li>
                <a href="#" class="hover:text-white transition-colors duration-200">Analytics</a>
              </li>
              <li>
                <a href="#" class="hover:text-white transition-colors duration-200">Settings</a>
              </li>
            </ul>
            <div class="h-4 w-px bg-white/10"></div>
            <.theme_toggle />
          </nav>
        </div>
      </header>
      
    <!-- Main Content -->
      <main class="relative container mx-auto px-4 py-12 sm:px-6 lg:px-8 max-w-7xl animate-fade-in-up">
        <!-- Geometric Accent - Top Right -->
        <div class="absolute -top-20 -right-20 w-96 h-96 bg-primary/20 rounded-full blur-3xl opacity-20 pointer-events-none mix-blend-screen">
        </div>
        <!-- Geometric Accent - Bottom Left -->
        <div class="absolute -bottom-20 -left-20 w-96 h-96 bg-secondary/10 rounded-full blur-3xl opacity-20 pointer-events-none mix-blend-screen">
        </div>

        <div class="relative z-10 w-full">
          {render_slot(@inner_block)}
        </div>
      </main>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end

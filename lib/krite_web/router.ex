defmodule KriteWeb.Router do
  use KriteWeb, :router

  import KriteWeb.AccountAuth,
    only: [
      fetch_current_account: 2,
      require_authenticated_budeie: 2,
      require_authenticated_kveg: 2
    ]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KriteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KriteWeb do
    pipe_through :browser

    live "/light", LightLive
    live "/sandbox", SandboxLive
    live "/sales", SalesLive
    live "/search", SearchLive
    live "/boats", BoatLive
    live "/servers", ServerLive
    live "/servers/:id", ServerLive
    live "/donations", DonationLive

    live "/candies", CandyLive.Index, :index
    live "/candies/new", CandyLive.Index, :new
    live "/candies/:id/edit", CandyLive.Index, :edit

    live "/thermostat", ThermostatLive, :greet
    live "/thermostat/:house", ThermostatLive

    get "/", PageController, :home

    resources "/kveg", KvegController
    resources "/purchases", PurchaseController
  end

  scope "/budeie", KriteWeb do
    pipe_through :browser

    get "/log-in", BudeieController, :new
    post "/log-in", BudeieController, :create
    delete "/log-out", BudeieController, :delete
  end

  scope "/budeie", KriteWeb do
    pipe_through [:browser, :require_authenticated_budeie]

    get "/", BudeieController, :index

    resources "/products", ProductController

    get "/settings", BudeieController, :edit
    put "/settings", BudeieController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", KriteWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:krite, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KriteWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

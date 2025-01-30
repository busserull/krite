defmodule KriteWeb.Router do
  use KriteWeb, :router

  import KriteWeb.AccountAuth,
    only: [
      fetch_logged_in_account: 2,
      require_authenticated_budeie: 2,
      require_authenticated_kveg: 2,
      require_not_logged_in: 2
    ]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KriteWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_logged_in_account
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KriteWeb do
    pipe_through :browser

    delete "/logout", LoginController, :delete
  end

  scope "/", KriteWeb do
    pipe_through [:browser, :require_not_logged_in]

    get "/", LoginController, :kveg_new
    post "/kveg-login", LoginController, :kveg_create

    get "/budeie-login", LoginController, :budeie_new
    post "/budeie-login", LoginController, :budeie_create

    get "/forgot-password", KvegPasswordResetController, :forgot_form
    post "/forgot-password", KvegPasswordResetController, :forgot_submit

    get "/reset-password/:handle", KvegPasswordResetController, :reset_form
    put "/reset-password/:handle", KvegPasswordResetController, :reset_submit
  end

  scope "/kveg", KriteWeb do
    pipe_through [:browser, :require_authenticated_kveg]

    get "/", KvegController, :index

    get "/account-top-up", InfoController, :dypet_account

    post "/sauna-pass-unremind", KvegController, :sauna_pass_unremind

    live "/shop", ShopLive
    live "/transactions", TransactionsLive

    get "/history", KvegController, :history
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

  # scope "/kveg", KriteWeb do
  #   pipe_through [:browser, :require_authenticated_kveg]
  # end

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

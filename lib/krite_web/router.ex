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

    get "/", PageController, :home

    resources "/kveg", KvegController
    resources "/items", ItemController
    resources "/purchases", PurchaseController
  end

  scope "/budeie", KriteWeb do
    pipe_through :browser

    get "/log_in", BudeieController, :new
    post "/log_in", BudeieController, :create
    delete "/log_out", BudeieController, :delete
    # get "/settings", AdminController, :edit
    # put "/settings", AdminController, :update
  end

  scope "/budeie", KriteWeb do
    pipe_through [:browser, :require_authenticated_budeie]

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

  ## Authentication routes

  # TODO: Add in something similar
  # scope "/", KriteWeb do
  #   pipe_through [:browser, :redirect_if_candy_is_authenticated]

  #   get "/candies/register", CandyRegistrationController, :new
  #   post "/candies/register", CandyRegistrationController, :create
  #   get "/candies/log_in", CandySessionController, :new
  #   post "/candies/log_in", CandySessionController, :create
  #   get "/candies/reset_password", CandyResetPasswordController, :new
  #   post "/candies/reset_password", CandyResetPasswordController, :create
  #   get "/candies/reset_password/:token", CandyResetPasswordController, :edit
  #   put "/candies/reset_password/:token", CandyResetPasswordController, :update
  # end

  # TODO: Add in something similar
  # scope "/", KriteWeb do
  #   pipe_through [:browser, :require_authenticated_candy]

  #   get "/candies/settings", CandySettingsController, :edit
  #   put "/candies/settings", CandySettingsController, :update
  #   get "/candies/settings/confirm_email/:token", CandySettingsController, :confirm_email
  # end

  scope "/", KriteWeb do
    pipe_through [:browser]

    delete "/candies/log_out", CandySessionController, :delete
    get "/candies/confirm", CandyConfirmationController, :new
    post "/candies/confirm", CandyConfirmationController, :create
    get "/candies/confirm/:token", CandyConfirmationController, :edit
    post "/candies/confirm/:token", CandyConfirmationController, :update
  end
end

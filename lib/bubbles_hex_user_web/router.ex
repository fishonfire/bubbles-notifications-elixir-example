defmodule BubblesHexUserWeb.Router do
  use BubblesHexUserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BubblesHexUserWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BubblesHexUserWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/notification", NotificationController, :new
    post "/notification", NotificationController, :create
    get "/notifications", NotificationController, :new
    post "/notifications", NotificationController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", BubblesHexUserWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bubbles_hex_user, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BubblesHexUserWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end

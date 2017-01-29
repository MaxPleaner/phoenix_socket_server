defmodule Server.Router do
  use Server.Web, :router
    use Addict.RoutesHelper


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end



  pipeline :api do
    plug :accepts, ["json"]
  end

  # Auth
  scope "/" do
    pipe_through :browser
    addict :routes
  end

  # Authenticated
  scope "/", Server do
    pipe_through [:browser]
    get "/", PageController, :index
    resources "/messages", MessageController, only: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Server do
  #   pipe_through :api
  # end
end

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

  pipeline :browser_auth do  
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end  

  # Auth
  scope "/" do
    pipe_through :browser
    addict :routes
  end

  # Authenticated
  scope "/", Server do
    pipe_through [:browser, :browser_auth]
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Server do
  #   pipe_through :api
  # end
end

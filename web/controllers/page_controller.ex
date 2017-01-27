defmodule Server.PageController do
  use Server.Web, :controller

  # Auth filter from addict is disabled. Using guardian instead.
  # -----------------------------------------------------------
  # plug Addict.Plugs.Authenticated when action in [:index]
  # -----------------------------------------------------------

  # Guardian plug validates the connection's JWT
  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def index(conn, _params) do
    IO.puts inspect conn
    user = Guardian.Plug.current_resource(conn)
    render conn, "index.html", user: user
  end

  # Guardian calls this upon failed auth
  def unauthenticated(conn, params) do
    conn
    |> put_status(401)
    |> put_flash(:info, "Authentication required")
    |> redirect(to: "/login")
  end

end

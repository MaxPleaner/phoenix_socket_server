defmodule Server.PageController do
  use Server.Web, :controller

  plug Addict.Plugs.Authenticated when action in [:index]

  def index(conn, _params) do
    user = current_user(conn)
    render conn, "index.html", user: user
  end

end

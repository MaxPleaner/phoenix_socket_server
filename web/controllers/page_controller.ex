defmodule Server.PageController do
  use Server.Web, :controller
  plug Addict.Plugs.Authenticated when action in [:index]
  def index(conn, _params) do
    render conn, "index.html"
  end
end

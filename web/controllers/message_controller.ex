require IEx


defmodule Server.MessageController do
  use Server.Web, :controller

  alias Server.Message
  
  def index(conn, %{"room" => room}) do
    messages = Repo.all( from m in Message, where: m.room == ^room, select: m )
    render(conn, "index.json", messages: messages)
  end

  def index(conn, _params) do
    render(conn, "missing_params.json", %{"missing_params" => ["room"]})
  end

end

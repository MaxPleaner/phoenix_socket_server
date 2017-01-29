require IEx


defmodule Server.MessageController do
  use Server.Web, :controller

  alias Server.Message
  
  plug Addict.Plugs.Authenticated
  
  def index(conn, %{"room" => room}) do
    if authenticated(conn, room) do
      messages = Repo.all( from m in Message, where: m.room == ^room, select: m )
      render(conn, "index.json", messages: messages)
    else
      conn
      |> put_status(401)
      |> render("unauthenticated.json", reason: "not a member of that room")
    end
  end

  def index(conn, _params) do
    conn
    |> put_status(422)
    |> render("missing_params.json", %{"missing_params" => ["room"]})
  end

  def authenticated(conn, room) do
    room
    |> String.split("-")
    |> Enum.member?(current_user(conn).email)
  end

end

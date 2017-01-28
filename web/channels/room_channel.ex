require IEx
defmodule Server.RoomChannel do
  import Ecto
  import Ecto.Query
  import Util.TypeOf

  alias SocketUtil.{RegisterRooms}
  alias Server.{Presence,Repo,User}

  use Phoenix.Channel

  use RegisterRooms, ["room:lobby"]

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", online_users(socket)
    {:ok, _} = Presence.track(
      socket,
      socket.assigns.current_user.id,
      %{
        online_at: inspect(System.system_time(:seconds)),
        email: socket.assigns.current_user.email
      }
    )
    {:noreply, socket}
  end
 
  def handle_in("global_msg", %{"body" => body}, socket) do
    broadcast! socket, "global_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_in("direct_msg", %{"body" => body, "email" => email}, socket) do
    room_id = Enum.sort([socket.assigns.current_user.email, email]) |> Enum.join("-")
    IO.puts inspect room_id
    room_name = "direct_msg-" <> room_id
    Server.Endpoint.broadcast("users_socket:#{email}", "new_msg", %{"body" => body, "email" => email})
    push socket, room_name, %{body: body }
    {:noreply, socket}
  end

  intercept ["direct_msg"]
  def handle_out("direct_msg-" <> msg_id, %{"body" => body, "email" => email}, socket) do
    if Enum.member?(String.split(msg_id, "-"), socket.assigns.current_user) do
      push socket, "direct_msg-#{msg_id}", %{"body" => body}
    end
    {:noreply, socket}
  end

  def handle_in(unknown, params, socket) do
    IO.puts "\n\nUNKNOWN MESSAGE: #{unknown}, params: #{inspect params}\n\n"
  end 

  def online_users(socket) do
    entries = Presence.list(socket)
    query =
      from u in User,
        where: u.id in ^Map.keys(entries),
        select: {u.id, u}
    users = query |> Repo.all |> Enum.into(%{})
    for {key, %{metas: metas}} <- entries, into: %{} do
      id_key = key |> String.to_integer
      user = users[id_key]
      user_attrs = %{
        email: user.email,
        id: user.id
      }
      {key, %{metas: metas, user: user_attrs}}
    end
  end


end

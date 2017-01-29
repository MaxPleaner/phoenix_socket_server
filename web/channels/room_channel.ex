require IEx
defmodule Server.RoomChannel do
  import Ecto
  import Ecto.Query
  import Util.TypeOf

  alias SocketUtil.{RegisterRooms}
  alias Server.{Presence,Repo,User,Message}

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

  def handle_in("direct_msg", %{"body" => body, "email" => toEmail}, socket) do
    fromEmail = socket.assigns.current_user.email
    room_id = Enum.sort([fromEmail, toEmail]) |> Enum.join("-")
    room_name = "direct_msg-" <> room_id
    send_if_authenticated socket, room_name, room_id, %{"body" => body, "fromEmail" => fromEmail }
    {:noreply, socket}
  end

  def send_if_authenticated(socket, room_name, room_id, params) do
    if Enum.member?(String.split(room_id, "-"), socket.assigns.current_user.email) do
      msg_record = %Message{
        fromEmail: params["fromEmail"],
        body: params["body"],
        room: room_id
      }
      Repo.insert!(msg_record)
      push socket, room_name, params
    end
    {:noreply, socket}
  end

  def handle_in(unknown, params, socket) do
    IO.puts "\n\nUNKNOWN MESSAGE: #{unknown}, params: #{inspect params}\n\n"
    {:noreply, socket}
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

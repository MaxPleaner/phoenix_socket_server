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
    IO.puts inspect fetch(socket.topic, Presence.list(socket))
    push socket, "presence_state", fetch(socket.topic, Presence.list(socket))
    {:ok, _} = Presence.track(
      socket,
      socket.assigns.current_user.id,
      %{ online_at: inspect(System.system_time(:seconds)) }
    )
    {:noreply, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast! socket, "new_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    push socket, "new_msg", payload
    {:noreply, socket}
  end

  def fetch(_topic, entries) do
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

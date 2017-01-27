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

  intercept ["presence_diff"]
  def handle_out("presence_diff", payload, socket) do
    final_payload = Enum.reduce([:leaves, :joins], payload, fn collection_key, payload ->
      Map.keys(payload[collection_key])
      |> Enum.each(fn id ->
        meta_record = payload[collection_key][id] 
        record = fetch(socket.topic, Presence.list(socket))
        |> Enum.find(fn user ->
          (user |> elem(1))[:metas][:phx_ref] == meta_record[:phx_ref]
        end)
      payload
    end)
    push socket, "presence_diff", final_payload
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

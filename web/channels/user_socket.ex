defmodule Server.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "room:*", Server.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
  timeout: 45_000
  # transport :longpoll, Phoenix.Transports.LongPoll

  alias Server.{Repo, User}
  def connect(%{"token" => token}, socket) do
    # 1 day = 86400 seconds
    case Phoenix.Token.verify(socket, "user", token, max_age: 86400) do
      {:ok, user_id} ->
        socket = assign(socket, :current_user, Repo.get!(User, user_id))
        {:ok, socket}
      {:error, _} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Server.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket) do
    IO.puts "socket id: "
    IO.puts "users_socket:#{socket.assigns.current_user.email}"
    "users_socket:#{socket.assigns.current_user.email}"
  end

end

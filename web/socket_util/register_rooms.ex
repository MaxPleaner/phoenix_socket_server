defmodule SocketUtil.RegisterRooms do

  defmacro __using__(names) do
    
    quote do
      for name <- unquote(names) do
        def join(name, _message, socket) do
          send(self, :after_join)
          { :ok, socket }
        end
      end
    end

  end

end
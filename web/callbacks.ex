defmodule Callbacks do
  

  defmodule PostLogin do
    import Server.Router.Helpers
    use Phoenix.Controller
    
    def run(conn, :ok, model) do
      conn
      |> Guardian.Plug.sign_in(model)
      |> redirect(to: "/")
    end

    def run(conn, :error, errors) do
      conn
      |> put_flash(:info, inspect(errors))
      |> redirect(to: "/login")
    end

  end

  defmodule PostLogout do
    import Server.Router.Helpers
    use Phoenix.Controller
    def run(conn, :ok, model) do
      conn
      |> Guardian.Plug.sign_out
      |> put_flash(:info, "Logged out")
      |> redirect(to: "/login")
    end

    def run(conn, :error, errors) do
      conn
      |> put_flash(:info, inspect(errors))
      |> redirect(to: "/login")
    end

  end
  
  defmodule PostRegister do
    import Server.Router.Helpers
    use Phoenix.Controller

    def run(conn, :ok, model) do
      Callbacks.PostLogin.run(conn, :ok, model)      
    end

    def run(conn, :error, errors) do
      conn
      |> put_flash(:info, inspect(errors))
      |> redirect(to: "/login")
    end

  end

end
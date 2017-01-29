defmodule Server.MessageView do
  use Server.Web, :view

  def render("missing_params.json", missing_params) do
    missing_params
  end

  def render("index.json", %{messages: messages}) do
    %{data: render_many(messages, Server.MessageView, "message.json")}
  end

  def render("show.json", %{message: message}) do
    %{data: render_one(message, Server.MessageView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    %{id: message.id,
      fromEmail: message.fromEmail,
      body: message.body,
      room: message.room}
  end
end

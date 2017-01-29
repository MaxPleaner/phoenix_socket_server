defmodule Server.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :fromEmail, :string
      add :body, :text
      add :room, :string

      timestamps()
    end

  end
end

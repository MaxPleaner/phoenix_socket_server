defmodule Server.Message do
  use Server.Web, :model

  schema "messages" do
    field :fromEmail, :string
    field :body, :string
    field :room, :string
    has_one :sender, Server.User, foreign_key: :email, references: :fromEmail
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:fromEmail, :body, :room])
    |> validate_required([:fromEmail, :body, :room])
  end
end

defmodule Server.User do
  use Server.Web, :model

  schema "users" do
    field :encrypted_password, :string
    field :email, :string
    has_many :messages, Server.Message, foreign_key: :fromEmail, references: :email
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:encrypted_password, :email])
    |> validate_required([:encrypted_password, :email])
  end
end

defmodule BubblesHexUser.Notifications.Notification do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{}

  embedded_schema do
    field :app_id, :integer
    field :auth_token, :string
    field :title, :string
    field :body, :string
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:app_id, :auth_token, :title, :body])
    |> validate_required([:app_id, :auth_token, :title, :body])
    |> validate_number(:app_id, greater_than: 0)
    |> validate_length(:title, max: 120)
    |> validate_length(:body, max: 1_000)
  end
end

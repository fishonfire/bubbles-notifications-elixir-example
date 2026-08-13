defmodule BubblesHexUser.Notifications.DevicePush do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{}

  embedded_schema do
    field :app_id, :integer
    field :auth_token, :string
    field :device_id, :string
    field :title, :string
    field :body, :string
    field :data, :string
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(device_push, attrs) do
    device_push
    |> cast(attrs, [:app_id, :auth_token, :device_id, :title, :body, :data])
    |> validate_required([:app_id, :auth_token, :device_id, :title, :body, :data])
    |> validate_number(:app_id, greater_than: 0)
    |> validate_length(:device_id, min: 1, max: 255)
    |> validate_length(:title, max: 120)
    |> validate_length(:body, max: 1_000)
    |> validate_length(:data, max: 5_000)
  end
end

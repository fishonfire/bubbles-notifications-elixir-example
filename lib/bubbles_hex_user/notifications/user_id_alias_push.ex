defmodule BubblesHexUser.Notifications.UserIdAliasPush do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  @type t :: %__MODULE__{}

  embedded_schema do
    field :app_id, :integer
    field :auth_token, :string
    field :user_ids, :string
    field :aliases, :string
    field :title, :string
    field :body, :string
    field :data, :string
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(user_id_alias_push, attrs) do
    user_id_alias_push
    |> cast(attrs, [:app_id, :auth_token, :user_ids, :aliases, :title, :body, :data])
    |> validate_required([:app_id, :auth_token, :title, :body, :data])
    |> validate_targets()
    |> validate_number(:app_id, greater_than: 0)
    |> validate_length(:user_ids, max: 5_000)
    |> validate_length(:aliases, max: 5_000)
    |> validate_length(:title, max: 120)
    |> validate_length(:body, max: 1_000)
    |> validate_length(:data, max: 5_000)
  end

  defp validate_targets(changeset) do
    user_ids = changeset |> get_field(:user_ids) |> target_items()
    aliases = changeset |> get_field(:aliases) |> target_items()

    if user_ids == [] and aliases == [] do
      changeset
      |> add_error(:user_ids, "must include at least one user ID or alias")
      |> add_error(:aliases, "must include at least one user ID or alias")
    else
      changeset
    end
  end

  defp target_items(value) when is_binary(value) do
    value
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp target_items(_value), do: []
end

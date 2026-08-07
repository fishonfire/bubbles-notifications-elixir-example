defmodule BubblesHexUser.Notifications do
  alias BubblesHexUser.Notifications.Notification

  @type send_result ::
          {:ok, map()}
          | {:error, :validation, Ecto.Changeset.t()}
          | {:error, :send, Exception.t() | map()}

  @spec change_notification(map()) :: Ecto.Changeset.t()
  def change_notification(attrs \\ %{}) do
    Notification.changeset(%Notification{}, attrs)
  end

  @spec send_notification(map()) :: send_result()
  def send_notification(attrs) do
    changeset = change_notification(attrs)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, notification} ->
        send_with_client(notification)

      {:error, changeset} ->
        {:error, :validation, changeset}
    end
  end

  @spec base_url() :: String.t() | nil
  def base_url do
    Application.get_env(:bubbles_notifications, :base_url)
  end

  @spec base_url_configured?() :: boolean()
  def base_url_configured? do
    case base_url() do
      value when is_binary(value) -> value != ""
      _ -> false
    end
  end

  defp send_with_client(notification) do
    client_module =
      Application.get_env(:bubbles_hex_user, :notifications_client, BubblesNotifications)

    try do
      client = client_module.initialize(notification.app_id, notification.auth_token)

      client_module.create_notification(client, %{
        title: notification.title,
        body: notification.body,
        data: %{}
      })
      |> normalize_send_result()
    rescue
      error in ArgumentError ->
        {:error, :send, error}
    end
  end

  defp normalize_send_result({:ok, response}) when is_map(response), do: {:ok, response}
  defp normalize_send_result({:error, error}), do: {:error, :send, error}
end

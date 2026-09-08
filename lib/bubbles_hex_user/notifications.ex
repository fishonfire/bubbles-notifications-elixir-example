defmodule BubblesHexUser.Notifications do
  alias BubblesHexUser.Notifications.{DevicePush, Notification, UserIdAliasPush}

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
        case parse_data_map(notification.data) do
          {:ok, data} ->
            send_with_client(notification.app_id, notification.auth_token, fn client_module,
                                                                              client ->
              client_module.create_notification(client, %{
                title: notification.title,
                body: notification.body,
                data: data
              })
            end)

          {:error, message} ->
            {:error, :validation,
             changeset
             |> Ecto.Changeset.add_error(:data, message)
             |> Map.put(:action, :insert)}
        end

      {:error, changeset} ->
        {:error, :validation, changeset}
    end
  end

  @spec change_device_push(map()) :: Ecto.Changeset.t()
  def change_device_push(attrs \\ %{}) do
    DevicePush.changeset(%DevicePush{}, attrs)
  end

  @spec send_device_push(map()) :: send_result()
  def send_device_push(attrs) do
    changeset = change_device_push(attrs)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, device_push} ->
        case parse_data_map(device_push.data) do
          {:ok, data} ->
            send_with_client(device_push.app_id, device_push.auth_token, fn client_module,
                                                                            client ->
              client_module.send_push_to_device(client, device_push.device_id, %{
                title: device_push.title,
                body: device_push.body,
                data: data
              })
            end)

          {:error, message} ->
            {:error, :validation,
             changeset
             |> Ecto.Changeset.add_error(:data, message)
             |> Map.put(:action, :insert)}
        end

      {:error, changeset} ->
        {:error, :validation, changeset}
    end
  end

  @spec change_user_id_alias_push(map()) :: Ecto.Changeset.t()
  def change_user_id_alias_push(attrs \\ %{}) do
    UserIdAliasPush.changeset(%UserIdAliasPush{}, attrs)
  end

  @spec send_user_id_alias_push(map()) :: send_result()
  def send_user_id_alias_push(attrs) do
    changeset = change_user_id_alias_push(attrs)

    case Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, user_id_alias_push} ->
        with {:ok, data} <- parse_data_map(user_id_alias_push.data),
             {:ok, user_ids} <-
               parse_required_list(user_id_alias_push.user_ids, :user_ids, "user IDs"),
             {:ok, aliases} <-
               parse_required_list(user_id_alias_push.aliases, :aliases, "aliases") do
          send_with_client(
            user_id_alias_push.app_id,
            user_id_alias_push.auth_token,
            fn client_module, client ->
              client_module.create_notification_user_ids_aliases(client, user_ids, aliases, %{
                title: user_id_alias_push.title,
                body: user_id_alias_push.body,
                data: data
              })
            end
          )
        else
          {:error, message} ->
            {:error, :validation,
             changeset
             |> Ecto.Changeset.add_error(:data, message)
             |> Map.put(:action, :insert)}

          {:error, field, message} ->
            {:error, :validation,
             changeset
             |> Ecto.Changeset.add_error(field, message)
             |> Map.put(:action, :insert)}
        end

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

  defp send_with_client(app_id, auth_token, request_fun) do
    client_module =
      Application.get_env(:bubbles_hex_user, :notifications_client, BubblesNotifications)

    try do
      client = client_module.initialize(app_id, auth_token)
      request_fun.(client_module, client) |> normalize_send_result()
    rescue
      error in ArgumentError ->
        {:error, :send, error}
    end
  end

  defp parse_data_map(data) when is_binary(data) do
    case Jason.decode(data) do
      {:ok, decoded} when is_map(decoded) -> {:ok, decoded}
      {:ok, _decoded} -> {:error, "must be a JSON object"}
      {:error, _reason} -> {:error, "must be valid JSON"}
    end
  end

  defp parse_required_list(value, field, label) do
    items =
      value
      |> String.split([",", "\n"], trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    case items do
      [] -> {:error, field, "must include at least one #{label}"}
      items -> {:ok, items}
    end
  end

  defp normalize_send_result({:ok, response}) when is_map(response), do: {:ok, response}
  defp normalize_send_result({:error, error}), do: {:error, :send, error}
end

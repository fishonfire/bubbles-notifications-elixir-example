defmodule BubblesHexUserWeb.NotificationController do
  use BubblesHexUserWeb, :controller

  alias BubblesHexUser.Notifications

  def new(conn, _params) do
    render_notification_page(conn,
      active_tab: :notification,
      form: notification_form(Notifications.change_notification()),
      result: nil
    )
  end

  def create(conn, %{"notification" => notification_params}) do
    case Notifications.send_notification(notification_params) do
      {:ok, response} ->
        conn
        |> put_flash(:info, "Notification sent successfully.")
        |> render_notification_page(
          active_tab: :notification,
          form: notification_form(Notifications.change_notification()),
          result: %{
            kind: :success,
            title: "Notification accepted by the API",
            payload: response
          }
        )

      {:error, :validation, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render_notification_page(
          active_tab: :notification,
          form: notification_form(changeset),
          result: nil
        )

      {:error, :send, error} ->
        conn
        |> put_flash(:error, notification_error_message(error))
        |> render_notification_page(
          active_tab: :notification,
          form: notification_form(Notifications.change_notification(notification_params)),
          result: %{
            kind: :error,
            title: "Notification request failed",
            payload: normalize_error(error)
          }
        )
    end
  end

  def device_new(conn, _params) do
    render_notification_page(conn,
      active_tab: :device,
      form: device_push_form(Notifications.change_device_push()),
      result: nil
    )
  end

  def device_create(conn, %{"device_push" => device_push_params}) do
    case Notifications.send_device_push(device_push_params) do
      {:ok, response} ->
        conn
        |> put_flash(:info, "Device push sent successfully.")
        |> render_notification_page(
          active_tab: :device,
          form: device_push_form(Notifications.change_device_push()),
          result: %{
            kind: :success,
            title: "Device push accepted by the API",
            payload: response
          }
        )

      {:error, :validation, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render_notification_page(
          active_tab: :device,
          form: device_push_form(changeset),
          result: nil
        )

      {:error, :send, error} ->
        conn
        |> put_flash(:error, notification_error_message(error))
        |> render_notification_page(
          active_tab: :device,
          form: device_push_form(Notifications.change_device_push(device_push_params)),
          result: %{
            kind: :error,
            title: "Device push request failed",
            payload: normalize_error(error)
          }
        )
    end
  end

  defp render_notification_page(conn, assigns) do
    render(conn, :new,
      active_tab: Keyword.fetch!(assigns, :active_tab),
      form: Keyword.fetch!(assigns, :form),
      result: Keyword.fetch!(assigns, :result),
      notification_base_url: Notifications.base_url(),
      notification_base_url_configured?: Notifications.base_url_configured?()
    )
  end

  defp notification_form(changeset), do: Phoenix.Component.to_form(changeset)
  defp device_push_form(changeset), do: Phoenix.Component.to_form(changeset, as: :device_push)

  defp notification_error_message(%{status: status}) do
    "Notification request failed with status #{status}."
  end

  defp notification_error_message(%_{} = error) do
    Exception.message(error)
  end

  defp notification_error_message(error) do
    inspect(error)
  end

  defp normalize_error(%{status: status, body: body}) do
    %{
      status: status,
      body: body
    }
  end

  defp normalize_error(%_{} = error) do
    %{
      error: Exception.message(error)
    }
  end

  defp normalize_error(error) do
    %{
      error: inspect(error)
    }
  end
end

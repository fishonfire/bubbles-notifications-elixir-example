defmodule BubblesHexUserWeb.NotificationController do
  use BubblesHexUserWeb, :controller

  alias BubblesHexUser.Notifications

  def new(conn, _params) do
    render(conn, :new,
      form: notification_form(Notifications.change_notification()),
      result: nil,
      notification_base_url: Notifications.base_url(),
      notification_base_url_configured?: Notifications.base_url_configured?()
    )
  end

  def create(conn, %{"notification" => notification_params}) do
    case Notifications.send_notification(notification_params) do
      {:ok, response} ->
        conn
        |> put_flash(:info, "Notification sent successfully.")
        |> render(:new,
          form: notification_form(Notifications.change_notification()),
          result: %{
            kind: :success,
            title: "Notification accepted by the API",
            payload: response
          },
          notification_base_url: Notifications.base_url(),
          notification_base_url_configured?: Notifications.base_url_configured?()
        )

      {:error, :validation, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:new,
          form: notification_form(changeset),
          result: nil,
          notification_base_url: Notifications.base_url(),
          notification_base_url_configured?: Notifications.base_url_configured?()
        )

      {:error, :send, error} ->
        conn
        |> put_flash(:error, notification_error_message(error))
        |> render(:new,
          form: notification_form(Notifications.change_notification(notification_params)),
          result: %{
            kind: :error,
            title: "Notification request failed",
            payload: normalize_error(error)
          },
          notification_base_url: Notifications.base_url(),
          notification_base_url_configured?: Notifications.base_url_configured?()
        )
    end
  end

  defp notification_form(changeset) do
    Phoenix.Component.to_form(changeset)
  end

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

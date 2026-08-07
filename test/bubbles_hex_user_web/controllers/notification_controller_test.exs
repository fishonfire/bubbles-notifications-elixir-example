defmodule BubblesHexUserWeb.NotificationControllerTest do
  use BubblesHexUserWeb.ConnCase

  setup do
    original_client = Application.get_env(:bubbles_hex_user, :notifications_client)
    original_base_url = Application.get_env(:bubbles_notifications, :base_url)

    on_exit(fn ->
      restore_env(:bubbles_hex_user, :notifications_client, original_client)
      restore_env(:bubbles_notifications, :base_url, original_base_url)
    end)

    :ok
  end

  test "GET /notifications renders the notification form", %{conn: conn} do
    conn = get(conn, ~p"/notifications")
    html = html_response(conn, 200)

    assert html =~ "Send a notification"
    assert html =~ ~s(id="notification-form")
    assert html =~ "App ID"
    assert html =~ "Auth token"
    assert html =~ "Title"
    assert html =~ "Text"
  end

  test "POST /notifications with invalid params shows validation errors", %{conn: conn} do
    conn =
      post(conn, ~p"/notifications", %{
        "notification" => %{
          "app_id" => "abc",
          "auth_token" => "",
          "title" => "",
          "body" => ""
        }
      })

    html = html_response(conn, 422)

    assert html =~ "Send a notification"
    assert html =~ "is invalid"
    assert html =~ "can&#39;t be blank"
  end

  test "POST /notifications sends a notification and renders the API response", %{conn: conn} do
    Application.put_env(
      :bubbles_hex_user,
      :notifications_client,
      BubblesHexUser.NotificationsClientStub
    )

    Application.put_env(:bubbles_notifications, :base_url, "http://example.test")

    conn =
      post(conn, ~p"/notifications", %{
        "notification" => %{
          "app_id" => "42",
          "auth_token" => "secret-token",
          "title" => "Heads up",
          "body" => "Deployment completed successfully"
        }
      })

    html = html_response(conn, 200)

    assert html =~ "Notification sent successfully."
    assert html =~ "Notification accepted by the API"
    assert html =~ "queued"
    assert html =~ "Deployment completed successfully"
  end

  defp restore_env(app, key, nil), do: Application.delete_env(app, key)
  defp restore_env(app, key, value), do: Application.put_env(app, key, value)
end

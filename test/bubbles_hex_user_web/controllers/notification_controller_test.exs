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
    assert html =~ "App notification"
    assert html =~ "Device push"
    assert html =~ "Data (JSON)"
  end

  test "POST /notifications with invalid params shows validation errors", %{conn: conn} do
    conn =
      post(conn, ~p"/notifications", %{
        "notification" => %{
          "app_id" => "abc",
          "auth_token" => "",
          "title" => "",
          "body" => "",
          "data" => ""
        }
      })

    html = html_response(conn, 422)

    assert html =~ "Send a notification"
    assert html =~ "is invalid"
    assert html =~ "can&#39;t be blank"
  end

  test "POST /notifications with invalid data JSON shows validation error", %{conn: conn} do
    conn =
      post(conn, ~p"/notifications", %{
        "notification" => %{
          "app_id" => "42",
          "auth_token" => "secret-token",
          "title" => "Heads up",
          "body" => "Deployment completed successfully",
          "data" => "not json"
        }
      })

    html = html_response(conn, 422)

    assert html =~ "must be valid JSON"
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
          "body" => "Deployment completed successfully",
          "data" => ~s({"type":"deploy","success":true})
        }
      })

    html = html_response(conn, 200)

    assert html =~ "Notification sent successfully."
    assert html =~ "Notification accepted by the API"
    assert html =~ "queued"
    assert html =~ "Deployment completed successfully"
    assert html =~ "deploy"
  end

  test "GET /push/notifications/device renders the device push form", %{conn: conn} do
    conn = get(conn, ~p"/push/notifications/device")
    html = html_response(conn, 200)

    assert html =~ "Send a device push"
    assert html =~ ~s(id="device-push-form")
    assert html =~ "Device ID"
    assert html =~ "Data (JSON)"
  end

  test "POST /push/notifications/device with invalid JSON shows validation errors", %{conn: conn} do
    conn =
      post(conn, ~p"/push/notifications/device", %{
        "device_push" => %{
          "app_id" => "42",
          "auth_token" => "secret-token",
          "device_id" => "device-123",
          "title" => "Direct ping",
          "body" => "This message targets one device.",
          "data" => "[]"
        }
      })

    html = html_response(conn, 422)

    assert html =~ "Send a device push"
    assert html =~ "must be a JSON object"
  end

  test "POST /push/notifications/device sends a device push and renders the API response", %{
    conn: conn
  } do
    Application.put_env(
      :bubbles_hex_user,
      :notifications_client,
      BubblesHexUser.NotificationsClientStub
    )

    Application.put_env(:bubbles_notifications, :base_url, "http://example.test")

    conn =
      post(conn, ~p"/push/notifications/device", %{
        "device_push" => %{
          "app_id" => "42",
          "auth_token" => "secret-token",
          "device_id" => "device-123",
          "title" => "Direct ping",
          "body" => "This message targets one device.",
          "data" => ~s({"screen":"inbox"})
        }
      })

    html = html_response(conn, 200)

    assert html =~ "Device push sent successfully."
    assert html =~ "Device push accepted by the API"
    assert html =~ "device-123"
    assert html =~ "inbox"
  end

  test "GET /user-id/alias renders the user ID and alias push form", %{conn: conn} do
    conn = get(conn, ~p"/user-id/alias")
    html = html_response(conn, 200)

    assert html =~ "Send by user ID and alias"
    assert html =~ ~s(id="user-id-alias-push-form")
    assert html =~ "User IDs"
    assert html =~ "Aliases"
    assert html =~ "Data (JSON)"
  end

  test "POST /user-id/alias with invalid JSON shows validation errors", %{conn: conn} do
    conn =
      post(conn, ~p"/user-id/alias", %{
        "user_id_alias_push" => %{
          "app_id" => "42",
          "auth_token" => "secret-token",
          "user_ids" => "user-123",
          "aliases" => "team:eng",
          "title" => "Segment ping",
          "body" => "This message targets matching users and aliases.",
          "data" => "[]"
        }
      })

    html = html_response(conn, 422)

    assert html =~ "Send by user ID and alias"
    assert html =~ "must be a JSON object"
  end

  test "POST /user-id/alias with no targets shows validation errors", %{conn: conn} do
    conn =
      post(conn, ~p"/user-id/alias", %{
        "user_id_alias_push" => %{
          "app_id" => "42",
          "auth_token" => "secret-token",
          "user_ids" => "",
          "aliases" => "",
          "title" => "Segment ping",
          "body" => "This message targets matching users and aliases.",
          "data" => ~s({"screen":"inbox"})
        }
      })

    html = html_response(conn, 422)

    assert html =~ "Send by user ID and alias"
    assert html =~ "must include at least one user ID or alias"
  end

  test "POST /user-id/alias sends a user ID and alias push and renders the API response", %{
    conn: conn
  } do
    Application.put_env(
      :bubbles_hex_user,
      :notifications_client,
      BubblesHexUser.NotificationsClientStub
    )

    Application.put_env(:bubbles_notifications, :base_url, "http://example.test")

    conn =
      post(conn, ~p"/user-id/alias", %{
        "user_id_alias_push" => %{
          "app_id" => "42",
          "auth_token" => "secret-token",
          "user_ids" => "user-123\nuser-456",
          "aliases" => "team:eng, beta",
          "title" => "Segment ping",
          "body" => "This message targets matching users and aliases.",
          "data" => ~s({"screen":"inbox"})
        }
      })

    html = html_response(conn, 200)

    assert html =~ "User ID and alias push sent successfully."
    assert html =~ "User ID and alias push accepted by the API"
    assert html =~ "user-123"
    assert html =~ "user-456"
    assert html =~ "team:eng"
    assert html =~ "beta"
    assert html =~ "inbox"
  end

  test "POST /user-id/alias sends an alias-only push and renders an empty user IDs array", %{
    conn: conn
  } do
    Application.put_env(
      :bubbles_hex_user,
      :notifications_client,
      BubblesHexUser.NotificationsClientStub
    )

    Application.put_env(:bubbles_notifications, :base_url, "http://example.test")

    conn =
      post(conn, ~p"/user-id/alias", %{
        "user_id_alias_push" => %{
          "app_id" => "42",
          "auth_token" => "secret-token",
          "user_ids" => "",
          "aliases" => "alias1, alias2",
          "title" => "Alias ping",
          "body" => "This message targets aliases only.",
          "data" => ~s({"screen":"inbox"})
        }
      })

    html = html_response(conn, 200)

    assert html =~ "User ID and alias push sent successfully."
    assert html =~ ~s(&quot;user_ids&quot;: [])
    assert html =~ "alias1"
    assert html =~ "alias2"
  end

  defp restore_env(app, key, nil), do: Application.delete_env(app, key)
  defp restore_env(app, key, value), do: Application.put_env(app, key, value)
end

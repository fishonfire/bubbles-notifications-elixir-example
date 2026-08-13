defmodule BubblesHexUser.NotificationsClientStub do
  def initialize(app_id, auth_token) do
    %{
      app_id: app_id,
      auth_token: auth_token
    }
  end

  def create_notification(client, attrs) do
    {:ok,
     %{
       "status" => "queued",
       "app_id" => client.app_id,
       "title" => attrs[:title],
       "body" => attrs[:body],
       "data" => attrs[:data]
     }}
  end

  def send_push_to_device(client, device_id, attrs) do
    {:ok,
     %{
       "status" => "queued",
       "app_id" => client.app_id,
       "device_id" => to_string(device_id),
       "title" => attrs[:title],
       "body" => attrs[:body],
       "data" => attrs[:data]
     }}
  end
end

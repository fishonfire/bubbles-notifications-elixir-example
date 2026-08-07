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
       "body" => attrs[:body]
     }}
  end
end

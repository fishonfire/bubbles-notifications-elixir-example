defmodule BubblesHexUserWeb.NotificationHTML do
  use BubblesHexUserWeb, :html

  embed_templates "notification_html/*"

  def formatted_result(result) do
    case Jason.encode(result, pretty: true) do
      {:ok, json} -> json
      {:error, _reason} -> inspect(result, pretty: true)
    end
  end
end

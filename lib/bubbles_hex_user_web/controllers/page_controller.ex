defmodule BubblesHexUserWeb.PageController do
  use BubblesHexUserWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

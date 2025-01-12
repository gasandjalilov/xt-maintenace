defmodule Server.PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    text(conn, "Welcome to Service")
  end
end

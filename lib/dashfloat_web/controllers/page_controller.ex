defmodule DashFloatWeb.PageController do
  use DashFloatWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: {DashFloatWeb.Layouts, :marketing})
  end
end

defmodule ExStacksWeb.Router do
  use ExStacksWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ExStacksWeb do
    pipe_through :api
  end
end

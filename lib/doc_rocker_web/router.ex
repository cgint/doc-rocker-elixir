defmodule DocRockerWeb.Router do
  use DocRockerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DocRockerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DocRockerWeb do
    pipe_through :browser

    live "/", HomeLive, :index
    live "/markdown-demo", MarkdownDemoLive, :index
  end

  scope "/api", DocRockerWeb do
    pipe_through :api

    post "/chat", ChatController, :create
    post "/rock", RockController, :create
  end
end

defmodule CatcastsPhx13Web.Router do
  use CatcastsPhx13Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(CatcastsPhx13.Plugs.SetUser)
  end

  pipeline :auth do
    plug(CatcastsPhx13Web.Plugs.RequireAuth)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", CatcastsPhx13Web do
    pipe_through([:browser, :auth])

    resources("/videos", VideoController, only: [:new, :create])
  end

  scope "/", CatcastsPhx13Web do
    # Use the default browser stack
    pipe_through(:browser)

    resources("/videos", VideoController, only: [:index, :show, :delete])
    get("/", PageController, :index)
  end

  scope "/auth", CatcastsPhx13Web do
    pipe_through(:browser)

    get("/signout", AuthController, :delete)
    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :new)
  end

  # Other scopes may use custom stacks.
  # scope "/api", CatcastsPhx13Web do
  #   pipe_through :api
  # end
end

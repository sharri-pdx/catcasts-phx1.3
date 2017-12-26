defmodule CatcastsPhx13Web.VideoController do
  use CatcastsPhx13Web, :controller
  use Rummage.Phoenix.Controller

  alias CatcastsPhx13.Videos
  alias CatcastsPhx13.Videos.{Video, YoutubeData}

  plug(:check_video_owner when action in [:delete])

  def index(conn, params) do
    {query, rummage} =
      Video
      |> Video.rummage(params["rummage"])

    videos = CatcastsPhx13.Repo.all(query)

    render(conn, "index.html", videos: videos, rummage: rummage)
  end

  def new(conn, _params) do
    changeset = Videos.change_video(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    case YoutubeData.has_valid_regex?(video_params) do
      nil ->
        changeset = Video.changeset(%Video{}, video_params)

        conn
        |> put_flash(:error, "Invalid YouTube URL")
        |> render("new.html", changeset: changeset)

      regex ->
        YoutubeData.create_or_show_video(conn, regex)
    end
  end

  def show(conn, %{"id" => id}) do
    video = Videos.get_video!(id)
    render(conn, "show.html", video: video)
  end

  def delete(conn, %{"id" => id}) do
    video = Videos.get_video!(id)
    {:ok, _video} = Videos.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  defp check_video_owner(conn, _params) do
    %{params: %{"id" => video_id}} = conn

    if CatcastsPhx13.Repo.get(Video, video_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You cannot do that")
      |> redirect(to: video_path(conn, :index))
      |> halt()
    end
  end
end

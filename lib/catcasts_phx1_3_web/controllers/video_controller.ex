defmodule CatcastsPhx13Web.VideoController do
  use CatcastsPhx13Web, :controller

  alias CatcastsPhx13.Videos
  alias CatcastsPhx13.Videos.Video

  def index(conn, _params) do
    videos = Videos.list_videos()
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params) do
    changeset = Videos.change_video(%Video{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}) do
    case has_valid_regex?(video_params) do
      nil ->
        changeset = Video.changeset(%Video{}, video_params)

        conn
        |> put_flash(:error, "Invalid YouTube URL")
        |> render("new.html", changeset: changeset)
      regex ->
        video_id = get_video_id(regex)

        video_data = get_json_data(video_id)
               |> decode_json_data()
               |> get_video_data()

        video_attrs = get_formatted_time(video_data)
                      |> create_video_attrs(video_data)

        changeset = create_changeset(conn, video_attrs)

        create_or_redirect?(changeset, conn, video_id)
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

  defp has_valid_regex?(video_params) do
    Regex.run(~r/(?:youtube\.com\/\S*(?:(?:\/e(?:mbed))?\/|watch\?(?:\S*?&?v\=))|youtu\.be\/)([a-zA-Z0-9_-]{6,11})/, video_params["video_id"])
  end

  defp get_video_id(regex) do
    List.first(tl(regex))
  end

  defp get_json_data(video_id) do
    HTTPoison.get! "https://www.googleapis.com/youtube/v3/videos?id=#{video_id}&key=#{System.get_env("YOUTUBE_API_KEY")}&part=snippet,statistics,contentDetails&fields=items(id,snippet(title,thumbnails(high)),statistics(viewCount),contentDetails(duration))"
  end

  defp decode_json_data(json_data) do
    Poison.decode!(json_data.body, keys: :atoms)
  end

  defp get_video_data(video) do
    hd(video.items)
  end

  defp get_formatted_time(video_data) do
    duration = tl(Regex.run(~r/PT(\d+H)?(\d+M)?(\d+S)?/, video_data.contentDetails.duration))

    [hours, minutes, seconds] =
      for x <- duration, do: hd(Regex.run(~r{\d+}, x) || ["0"]) |> String.to_integer

    {_status, time} = Time.new(hours, minutes, seconds)
    Time.to_string(time)
  end

  defp create_video_attrs(duration, video_data) do
    %{duration: duration, thumbnail: video_data.snippet.thumbnails.high.url,
      title: video_data.snippet.title, video_id: video_data.id,
      view_count: String.to_integer(video_data.statistics.viewCount)}
  end

  defp create_changeset(conn, video_attrs) do
    conn.assigns.user
    |> Ecto.build_assoc(:videos)
    |> Video.changeset(video_attrs)
  end

  defp create_or_redirect?(changeset, conn, video_id) do
    case CatcastsPhx13.Repo.insert(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, _video} ->
        video = CatcastsPhx13.Video |> CatcastsPhx13.Repo.get_by(video_id: video_id)
        conn
        |> put_flash(:info, "Video has already been created.")
        |> redirect(to: video_path(conn, :show, video))
    end
  end
end

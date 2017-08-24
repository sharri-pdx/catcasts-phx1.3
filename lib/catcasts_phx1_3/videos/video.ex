defmodule CatcastsPhx13.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset
  alias CatcastsPhx13.Videos.Video
  alias CatcastsPhx13.User


  schema "videos" do
    field :duration, :string
    field :thumbnail, :string
    field :title, :string
    field :video_id, :string
    field :view_count, :integer
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Video{} = video, attrs) do
    video
    |> cast(attrs, [:video_id, :title, :duration, :thumbnail, :view_count])
    |> validate_required([:video_id, :title, :duration, :thumbnail, :view_count])
  end
end

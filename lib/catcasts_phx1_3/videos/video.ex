defmodule CatcastsPhx13.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset
  alias CatcastsPhx13.Videos.Video


  schema "videos" do
    field :duration, :string
    field :thumbnail, :string
    field :title, :string
    field :video_id, :string
    field :view_count, :integer
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Video{} = video, attrs) do
    video
    |> cast(attrs, [:video_id, :title, :duration, :thumbnail, :view_count])
    |> validate_required([:video_id, :title, :duration, :thumbnail, :view_count])
  end
end

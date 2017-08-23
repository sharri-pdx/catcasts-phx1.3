defmodule CatcastsPhx13.Factory do
  use ExMachina.Ecto, repo: CatcastsPhx13.Repo

  def user_factory do
    %CatcastsPhx13.User{
      token: "ffnebyt73bich9",
      email: "batman@example.com",
      first_name: "Bruce",
      last_name: "Wayne",
      provider: "google"
    }
  end
end

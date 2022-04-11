defmodule ExAthena.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: ExAthena.Repo
  use ExAthena.ConfigFactory

  def user_factory do
    web_auth_token = Faker.String.base64()
    email = Faker.Internet.email()

    password =
      Faker.String.base64()
      |> Pbkdf2.hash_pwd_salt()

    %ExAthena.Accounts.User{
      username: Faker.Internet.user_name(),
      email: email,
      encrypted_email: email,
      password: password,
      account_type: :player,
      sex: :masculine,
      role: :player,
      birth_at: Faker.Date.date_of_birth(),
      session_count: 0,
      character_slots: 0,
      web_auth_token: web_auth_token,
      encrypted_web_auth_token: web_auth_token,
      web_auth_token_enabled: true
    }
  end

  def ban_factory do
    banned_until =
      Timex.now()
      |> Timex.shift(days: 30)

    %ExAthena.Accounts.Ban{
      user: build(:user),
      banned_until: banned_until
    }
  end
end

defmodule ExAthenaLogger.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: ExAthenaLogger.Repo

  alias ExAthena.Factory, as: MainFactory

  def authentication_log_factory do
    ip = Faker.Internet.ip_v4_address()

    %ExAthenaLogger.Sql.AuthenticationLog{
      user: MainFactory.build(:user),
      socket_fd: 30,
      message: Faker.Lorem.Shakespeare.romeo_and_juliet(),
      metadata: %{},
      encrypted_ip: ip,
      ip: ip
    }
  end
end

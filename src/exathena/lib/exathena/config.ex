defmodule ExAthena.Config do
  @moduledoc """
  The ExAthena Config context.

  It handles all .conf files located at `settings`
  path in root umbrella project.
  """
  use ExAthena.IO

  alias ExAthena.Config.LoginAthena

  configure :conf do
    item :login_athena,
      name: LoginAthenaConfig,
      category: :server,
      reload?: false,
      schema: LoginAthena
  end
end

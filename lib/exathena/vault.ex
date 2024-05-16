defmodule ExAthena.Vault do
  # It is the app used by `Cloak` to manage encryption.
  @moduledoc false

  use Cloak.Vault, otp_app: :exathena
end

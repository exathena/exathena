defmodule ExAthena.Encrypted.Binary do
  # This module is a custom data type for encrypting string fields
  # using `Cloak`.
  @moduledoc false

  use Cloak.Ecto.Binary, vault: ExAthena.Vault
end

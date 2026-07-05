defmodule ExAthena.Encrypted.Binary do
  @moduledoc false
  use Cloak.Ecto.Binary, vault: ExAthena.Vault
end

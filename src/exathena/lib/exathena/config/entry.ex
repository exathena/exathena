defmodule ExAthena.Config.Entry do
  @moduledoc false

  @struct [
    # The config id (Default: nil)
    id: nil,
    # The config name (Default: nil)
    name: nil,
    # The config type (Default: nil)
    type: nil,
    # The config path (Default: nil)
    path: nil,
    # Should reload with command? (Default: true)
    reload?: true,
    # The config's schema (Default: nil)
    schema: nil,
    # The parsed and casted config (Default: nil)
    data: nil
  ]

  defstruct @struct

  @typedoc """
  The Config entry type.
  """
  @type t :: %__MODULE__{}
end

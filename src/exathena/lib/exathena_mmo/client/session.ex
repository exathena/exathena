defmodule ExAthenaMmo.Client.LoginSession do
  @moduledoc """
  The Client's socket session representation schema.
  """
  alias ExAthena.Accounts.User

  @typedoc """
  The Login Session struct
  """
  @type t :: %__MODULE__{
          id: pos_integer(),
          user: User.t() | nil,
          socket: port(),
          fd: pos_integer()
        }

  defstruct [:id, :user, :socket, :fd]
end

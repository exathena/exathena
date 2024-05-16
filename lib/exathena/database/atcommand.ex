defmodule ExAthena.Database.AtCommand do
  @moduledoc """
  The `database/atcommands_db.yml` schema representation
  """
  use ExAthena.Database, database: AtCommandDb

  @typedoc """
  The AtCommand type
  """
  @type t :: %__MODULE__{
          command: String.t(),
          aliases: list(String.t()),
          help: String.t()
        }

  @fields ~w(command aliases help)a

  @primary_key {:command, :string, source: :Command}

  schema "atcommands_db.yml" do
    field :aliases, {:array, :string}, source: :Aliases
    field :help, :string, source: :Help
  end

  @doc """
  Generates the changeset for a given @command (atcommand).

  ## Examples

      iex> AtCommand.changeset(%AtCommand{}, %{
      ...>  command: "foo",
      ...>  aliases: ["bar"],
      ...>  help: "baz"
      ...> })
      %Ecto.Changeset{valid?: true}

      iex> AtCommand.changeset(%AtCommand{}, %{})
      %Ecto.Changeset{valid?: false}

  """
  def changeset(atcommand = %__MODULE__{}, attrs) do
    atcommand
    |> cast(parse_attrs(attrs), @fields)
    |> validate_required([:command])
  end
end

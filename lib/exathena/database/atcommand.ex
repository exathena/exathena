defmodule ExAthena.Database.AtCommand do
  @moduledoc """
  The `database/atcommands_db.yml` schema representation
  """
  use ExAthena.Database

  @typedoc """
  The AtCommand type
  """
  @type t :: %__MODULE__{
          command: String.t(),
          aliases: list(String.t()),
          help: String.t()
        }

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
  def changeset(atcommand, attrs) do
    attrs = parse_attrs(attrs)

    atcommand
    |> cast(attrs, [:command, :aliases, :help])
    |> validate_required([:command])
  end
end

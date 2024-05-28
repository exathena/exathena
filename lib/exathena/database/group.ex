defmodule ExAthena.Database.Group do
  @moduledoc """
  The `database/groups_db.yml` schema representation
  """
  use ExAthena.Database

  @typedoc """
  The role type
  """
  @type role ::
          :player
          | :super_player
          | :support
          | :script_manager
          | :event_manager
          | :vip
          | :law_enforcement
          | :admin

  @typedoc """
  The Group type
  """
  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          role: role(),
          level: String.t(),
          inherit: list(String.t()),
          commands: map(),
          permissions: map()
        }

  @allowed_roles ~w(
    player
    super_player
    support
    script_manager
    event_manager
    vip
    law_enforcement
    admin
  )a

  @primary_key {:id, :integer, source: :Id}
  schema "groups_db.yml" do
    field :name, :string, source: :Name
    field :role, Ecto.Enum, values: @allowed_roles, source: :Role
    field :level, :integer, source: :Level
    field :log_commands?, :boolean, source: :LogCommands
    field :inherit, {:array, :string}, source: :Inherit
    field :commands, :map, source: :Commands
    field :char_commands, :map, source: :CharCommands
    field :permissions, :map, source: :Permissions
  end

  @doc """
  Generates the changeset for a given group.

  ## Examples

      iex> Group.changeset(%Group{}, %{
      ...>  id: 0,
      ...>  name: "Foo",
      ...>  role: :foo
      ...> })
      %Ecto.Changeset{valid?: true}

      iex> Group.changeset(%Group{}, %{})
      %Ecto.Changeset{valid?: false}

  """
  def changeset(group, attrs) do
    attrs = parse_attrs(attrs)

    group
    |> cast(attrs, [:id, :name, :role, :level, :inherit, :log_commands?, :commands, :permissions])
    |> validate_required([:id, :name, :role])
  end

  @doc false
  def __allowed_roles__, do: @allowed_roles
end

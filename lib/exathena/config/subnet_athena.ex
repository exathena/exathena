defmodule ExAthena.Config.SubnetAthena do
  @moduledoc """
  The `conf/subnet_athena.conf` schema representation.
  """
  use ExAthena, :schema

  @typedoc """
  The Exathena `subnet_athena.conf` type.
  """
  @type t :: %__MODULE__{
          net_submark: String.t(),
          char_ip: String.t(),
          map_ip: String.t()
        }

  @fields ~w(net_submark char_ip map_ip)a

  @primary_key false
  schema "subnet_athena.conf" do
    field :net_submark, :string, default: "255.0.0.0"
    field :char_ip, :string, default: "127.0.0.1"
    field :map_ip, :string, default: "127.0.0.1"
  end

  @doc """
  Generates the changeset for a given subnet athena.

  ## Examples

      iex> SubnetAthena.changeset(%SubnetAthena{}, valid_attrs)
      %Ecto.Changeset{valid?: true}

      iex> SubnetAthena.changeset(%SubnetAthena{}, %{})
      %Ecto.Changeset{valid?: false}

  """
  def changeset(subnet_athena, attrs)

  def changeset(subnet_athena = %__MODULE__{}, %{"subnet" => subnet}) do
    [net_submark, char_ip, map_ip] = String.split(subnet, ":")

    attrs = %{
      net_submark: net_submark,
      char_ip: char_ip,
      map_ip: map_ip
    }

    changeset(subnet_athena, attrs)
  end

  def changeset(subnet_athena = %__MODULE__{}, attrs) do
    subnet_athena
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end

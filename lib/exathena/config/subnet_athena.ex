defmodule ExAthena.Config.SubnetAthena do
  @moduledoc """
  The `conf/subnet_athena.conf` schema representation.
  """
  use ExAthena, :schema

  @typedoc """
  The ExAthena `subnet_athena.conf` type.
  """
  @type t :: %__MODULE__{
          net_submark: String.t(),
          char_ip: String.t(),
          map_ip: String.t()
        }

  @primary_key false
  schema "subnet_athena.conf" do
    field :net_submark, :string, default: "255.0.0.0"
    field :char_ip, :string, default: "127.0.0.1"
    field :map_ip, :string, default: "127.0.0.1"
  end

  @doc false
  def changeset(subnet_athena, %{"subnet" => subnet}) do
    [net_submark, char_ip, map_ip] = String.split(subnet, ":")

    changeset(subnet_athena, %{
      net_submark: net_submark,
      char_ip: char_ip,
      map_ip: map_ip
    })
  end

  def changeset(subnet_athena, attrs) do
    subnet_athena
    |> cast(attrs, [:net_submark, :char_ip, :map_ip])
    |> validate_required([:net_submark, :char_ip, :map_ip])
  end
end

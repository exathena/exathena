defmodule UpdatedConfig do
  @moduledoc false
  use ExAthena, :schema

  @fields ~w(
    date_format min_group_id_to_connect vip_group ipban_dynamic_pass_failure_ban usercount_medium use_dnsbl
    ipban_dynamic_pass_failure_ban_limit console allowed_regs console_silent dnsbl_servers log_login
    new_acc_length_limit vip_char_increase usercount_high stdout_with_ansisequence client_hash_check group_id_to_connect
    ipban_dynamic_pass_failure_ban_duration console_log_filepath time_allowed use_MD5_passwords
    ipban_dynamic_pass_failure_ban_interval new_account usercount_disable use_web_auth_token login_port start_limited_time
    ipban_cleanup_interval console_msg_log login_log_filename chars_per_account ipban_enable usercount_low
  )a

  @allowed_logger_level ~w(info debug warn error)a
  @allowed_console_silent ~w(none info status notice warn error debug)a

  @primary_key false
  schema "updated_config.conf" do
    field :date_format, :string, default: "%Y-%m-%d %H:%M:%S"
    field :min_group_id_to_connect, :integer, default: -1
    field :vip_group, :integer, integer: 5
    field :ipban_dynamic_pass_failure_ban, :boolean, default: true
    field :usercount_medium, :integer, default: 500
    field :use_dnsbl, :boolean, default: true
    field :ipban_dynamic_pass_failure_ban_limit, :integer, default: 7
    field :console, :boolean, default: true
    field :allowed_regs, :integer, default: 1
    field :console_silent, Ecto.Enum, values: @allowed_console_silent, default: :none
    field :dnsbl_servers, {:array, :string}, default: ["bl.blocklist.de", "socks.dnsbl.sorbs.net"]
    field :log_login, :boolean, default: true
    field :new_acc_length_limit, :boolean, default: true
    field :vip_char_increase, :integer, default: -1
    field :usercount_high, :integer, default: 1000
    field :stdout_with_ansisequence, :boolean, default: true
    field :client_hash_check, :boolean, default: true
    field :group_id_to_connect, :integer, default: -1
    field :ipban_dynamic_pass_failure_ban_duration, :integer, default: 5
    field :console_log_filepath, :string, default: "./log/login-msg_log.log"
    field :time_allowed, :integer, default: 10
    field :use_MD5_passwords, :boolean, default: true
    field :ipban_dynamic_pass_failure_ban_interval, :integer, default: 5
    field :new_account, :boolean, default: true
    field :usercount_disable, :boolean, default: true
    field :use_web_auth_token, :boolean, default: true
    field :login_port, :integer, default: 6900
    field :start_limited_time, :integer, default: -1
    field :ipban_cleanup_interval, :integer, default: 60
    field :console_msg_log, Ecto.Enum, values: @allowed_logger_level, default: :info
    field :login_log_filename, :string, default: "log/login.log"
    field :chars_per_account, :integer, default: 0
    field :ipban_enable, :boolean, default: true
    field :usercount_low, :integer, default: 200
  end

  @doc false
  def changeset(login_athena = %__MODULE__{}, attrs) do
    login_athena
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_inclusion(:console_msg_log, @allowed_logger_level)
    |> validate_inclusion(:console_silent, @allowed_console_silent)
  end
end

defmodule InvalidConfig do
  @moduledoc false
  use ExAthena, :schema

  schema "invalid_config.conf" do
    field :use_web_auth_token, :boolean
  end

  @doc false
  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:use_web_auth_token])
    |> validate_required([:use_web_auth_token])
  end
end

defmodule InvalidFormatConfig do
  @moduledoc false
  use ExAthena, :schema

  schema "partial_valid_config.conf" do
  end
end

defmodule InvalidDatabase do
  use ExAthena.Database

  @allowed_roles ~w(super_player)a

  @fields ~w(id name role level inherit log_commands? commands permissions)a
  @required_fields ~w(id name role)a

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

  @doc false
  def changeset(group = %__MODULE__{}, attrs) do
    group
    |> cast(parse_attrs(attrs), @fields)
    |> validate_inclusion(:role, @allowed_roles)
    |> validate_required(@required_fields)
  end
end

defmodule InvalidFormatDatabase do
  use ExAthena, :schema

  schema "invalid_format.yml" do
  end
end

defmodule InvalidPathDatabase do
  use ExAthena, :schema

  schema "foo.yml" do
  end
end

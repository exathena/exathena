defmodule ExAthena.Config.LoginAthena do
  @moduledoc """
  The `conf/login_athena.conf` schema representation.
  """
  use ExAthena, :schema

  @typedoc """
  The ExAthena `login_athena.conf` type.
  """
  @type t :: %__MODULE__{
          bind_ip: String.t(),
          date_format: String.t(),
          min_group_id_to_connect: integer(),
          vip_group: non_neg_integer(),
          ipban_dynamic_pass_failure_ban: boolean(),
          usercount_medium: non_neg_integer(),
          use_dnsbl: boolean(),
          ipban_dynamic_pass_failure_ban_limit: non_neg_integer(),
          console: boolean(),
          allowed_regs: non_neg_integer(),
          console_silent: atom(),
          dnsbl_servers: list(String.t()),
          log_login: boolean(),
          new_acc_length_limit: boolean(),
          vip_char_increase: integer(),
          usercount_high: non_neg_integer(),
          stdout_with_ansisequence: boolean(),
          client_hash_check: boolean(),
          group_id_to_connect: integer(),
          ipban_dynamic_pass_failure_ban_duration: non_neg_integer(),
          console_log_filepath: String.t(),
          time_allowed: non_neg_integer(),
          use_MD5_passwords: boolean(),
          ipban_dynamic_pass_failure_ban_interval: non_neg_integer(),
          new_account: boolean(),
          usercount_disable: boolean(),
          use_web_auth_token: boolean(),
          login_port: non_neg_integer(),
          start_limited_time: integer(),
          ipban_cleanup_interval: non_neg_integer(),
          console_msg_log: atom(),
          login_log_filename: String.t(),
          chars_per_account: non_neg_integer(),
          ipban_enable: boolean(),
          usercount_low: non_neg_integer()
        }

  @fields ~w(
    date_format min_group_id_to_connect vip_group ipban_dynamic_pass_failure_ban usercount_medium use_dnsbl
    ipban_dynamic_pass_failure_ban_limit console allowed_regs console_silent dnsbl_servers log_login
    new_acc_length_limit vip_char_increase usercount_high stdout_with_ansisequence client_hash_check group_id_to_connect
    ipban_dynamic_pass_failure_ban_duration console_log_filepath time_allowed use_MD5_passwords
    ipban_dynamic_pass_failure_ban_interval new_account usercount_disable use_web_auth_token login_port start_limited_time
    ipban_cleanup_interval console_msg_log login_log_filename chars_per_account ipban_enable usercount_low
    bind_ip
  )a

  @allowed_logger_level ~w(info debug warn error)a
  @allowed_console_silent ~w(none info status notice warn error debug)a

  @primary_key false
  schema "login_athena.conf" do
    field :bind_ip, :string, default: "127.0.0.1"
    field :date_format, :string, default: "%Y-%m-%d %H:%M:%S"
    field :min_group_id_to_connect, :integer, default: -1
    field :vip_group, :integer, default: 5
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

  @doc """
  Generates the changeset for a given login athena.

  ## Examples

      iex> LoginAthena.changeset(%LoginAthena{}, valid_attrs)
      %Ecto.Changeset{valid?: true}

      iex> LoginAthena.changeset(%LoginAthena{}, %{})
      %Ecto.Changeset{valid?: false}

  """
  def changeset(login_athena, attrs) do
    login_athena
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end

defmodule ExAthena.Factory do
  @moduledoc false

  defp factory(:user) do
    web_auth_token = Faker.String.base64()
    email = Faker.Internet.email()

    password =
      Faker.String.base64()
      |> Pbkdf2.hash_pwd_salt()

    %ExAthena.Accounts.User{
      username: Faker.Internet.user_name(),
      email: email,
      encrypted_email: email,
      password: password,
      account_type: :player,
      sex: :masculine,
      role: :player,
      birth_at: Faker.Date.date_of_birth(),
      session_count: 0,
      character_slots: 0,
      web_auth_token: web_auth_token,
      encrypted_web_auth_token: web_auth_token,
      web_auth_token_enabled: true
    }
  end

  defp factory(:ban) do
    banned_until =
      Timex.now()
      |> Timex.shift(days: 30)

    %ExAthena.Accounts.Ban{
      user: build(:user),
      banned_until: banned_until
    }
  end

  defp factory(:subscription) do
    until =
      Timex.now()
      |> Timex.shift(days: 30)

    %ExAthena.Accounts.Subscription{
      user: build(:user),
      until: until
    }
  end

  defp factory(:login_athena) do
    %ExAthena.Config.LoginAthena{
      bind_ip: "127.0.0.1",
      stdout_with_ansisequence: true,
      ipban_enable: true,
      usercount_low: 200,
      use_dnsbl: true,
      group_id_to_connect: -1,
      usercount_high: 1000,
      allowed_regs: 1,
      time_allowed: 10,
      new_account: true,
      client_hash_check: true,
      vip_char_increase: -1,
      console_log_filepath: "./log/login-msg_log.log",
      start_limited_time: -1,
      dnsbl_servers: ["bl.blocklist.de", "socks.dnsbl.sorbs.net"],
      console_msg_log: :info,
      ipban_dynamic_pass_failure_ban_limit: 7,
      usercount_medium: 500,
      usercount_disable: true,
      console_silent: :none,
      use_MD5_passwords: true,
      vip_group: 5,
      min_group_id_to_connect: -1,
      chars_per_account: 0,
      login_port: 6900,
      use_web_auth_token: true,
      date_format: "%Y-%m-%d %H:%M:%S",
      log_login: true,
      ipban_dynamic_pass_failure_ban: true,
      console: true,
      login_log_filename: "log/login.log",
      new_acc_length_limit: true,
      ipban_dynamic_pass_failure_ban_interval: 5,
      ipban_cleanup_interval: 60,
      ipban_dynamic_pass_failure_ban_duration: 5
    }
  end

  defp factory(:subnet_athena) do
    %ExAthena.Config.SubnetAthena{
      net_submark: "255.0.0.0",
      char_ip: "127.0.0.1",
      map_ip: "127.0.0.1"
    }
  end

  defp factory(:atcommand) do
    %ExAthena.Database.AtCommand{
      command: "help",
      aliases: ["h"],
      help: "Show message help"
    }
  end

  defp factory(:group) do
    %ExAthena.Database.Group{
      id: 0,
      name: "Player",
      role: :player,
      level: 0,
      inherit: nil,
      commands: %{
        "changedress" => true,
        "resurrect" => true
      },
      permissions: %{
        "can_trade" => true,
        "can_party" => true,
        "attendance" => true
      }
    }
  end

  defp factory(:authentication_log) do
    %ExAthena.Accounts.AuthenticationLog{
      user: factory(:user),
      message: Faker.Lorem.Shakespeare.romeo_and_juliet(),
      metadata: %{}
    }
  end

  # Convenience-like API

  def build(name, attrs \\ %{}) do
    name |> factory() |> struct!(attrs)
  end

  def insert(name, attrs \\ %{}) do
    name |> build(attrs) |> insert!()
  end

  def params_for(name, attrs \\ %{}) do
    name |> build(attrs) |> Map.from_struct()
  end

  def params_with_assocs(name, attrs \\ %{}) do
    name |> build(attrs) |> Map.from_struct()
  end

  def string_params_for(name, attrs \\ %{}) do
    name |> params_for(attrs) |> Map.drop([:__meta__]) |> Jason.encode!() |> Jason.decode!()
  end

  # Helpers

  defp insert!(%_{} = struct) do
    ExAthena.Repo.insert!(struct)
  end
end

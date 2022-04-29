defmodule ExAthena.ConfigFactory do
  @moduledoc false

  @doc false
  defmacro __using__(_) do
    quote do
      def login_athena_factory do
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

      def subnet_athena_factory do
        %ExAthena.Config.SubnetAthena{
          net_submark: "255.0.0.0",
          char_ip: "127.0.0.1",
          map_ip: "127.0.0.1"
        }
      end
    end
  end
end

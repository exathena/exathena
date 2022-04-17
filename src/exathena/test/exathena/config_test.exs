defmodule ExAthena.ConfigTest do
  use ExAthena.DataCase
  @moduletag capture_log: true

  alias ExAthena.Config
  alias ExAthena.Config.{Entry, LoginAthena}

  @updated_config_file "./test/support/settings/updated_config.conf"
  @invalid_format_config_file "./test/support/settings/invalid_format.conf"

  describe "init/1" do
    test "returns the new state with data loaded" do
      assert entry = %Entry{data: nil} = build(:config_entry)

      func = fn ->
        assert {:ok, %Entry{data: %LoginAthena{}}} = Config.init(entry)
      end

      captured_log = capture_log(func)

      assert captured_log =~ "Reading file #{entry.path}"
      refute captured_log =~ "Failed to parse #{entry.path} due to invalid_format at line 5"
      refute captured_log =~ "Failed to read #{Path.basename(entry.path)}"
    end

    test "returns error when file has invalid path" do
      assert entry = %Entry{data: nil} = build(:config_entry, path: "foo/bar.conf")

      func = fn ->
        assert {:stop, :invalid_path} = Config.init(entry)
      end

      captured_log = capture_log(func)

      assert captured_log =~ "Reading file #{entry.path}"
      refute captured_log =~ "Failed to parse #{entry.path} due to invalid_format at line 5"
      assert captured_log =~ "Failed to read #{Path.basename(entry.path)}"
    end

    test "returns error when file has invalid format" do
      assert entry = %Entry{data: nil} = build(:config_entry, path: @invalid_format_config_file)

      func = fn ->
        assert {:stop, :invalid_format} = Config.init(entry)
      end

      captured_log = capture_log(func)

      assert captured_log =~ "Reading file #{entry.path}"
      assert captured_log =~ "Failed to parse #{entry.path} due to invalid_format at line 5"
      assert captured_log =~ "Failed to read #{Path.basename(entry.path)}"
    end
  end

  describe "start_link/1" do
    test "returns the pid from new GenServer" do
      assert entry = %Entry{data: nil} = build(:config_entry)

      func = fn ->
        assert {:ok, pid} = Config.start_link(entry)
        assert is_pid(pid)
      end

      captured_log = capture_log(func)

      assert captured_log =~ "Reading file #{entry.path}"
      refute captured_log =~ "Failed to parse #{entry.path} due to invalid_format at line 5"
      refute captured_log =~ "Failed to read #{Path.basename(entry.path)}"
    end

    test "returns error when file has invalid path" do
      assert entry = %Entry{data: nil} = build(:config_entry, path: "foo/bar.conf")

      func = fn ->
        assert {:error, :invalid_path} = Config.start_link(entry)
      end

      captured_log = capture_log(func)

      assert captured_log =~ "Reading file #{entry.path}"
      refute captured_log =~ "Failed to parse #{entry.path} due to invalid_format at line 5"
      assert captured_log =~ "Failed to read #{Path.basename(entry.path)}"
    end

    test "returns error when file has invalid format" do
      assert entry = %Entry{data: nil} = build(:config_entry, path: @invalid_format_config_file)

      func = fn ->
        assert {:error, :invalid_format} = Config.start_link(entry)
      end

      captured_log = capture_log(func)

      assert captured_log =~ "Reading file #{entry.path}"
      assert captured_log =~ "Failed to parse #{entry.path} due to invalid_format at line 5"
      assert captured_log =~ "Failed to read #{Path.basename(entry.path)}"
    end
  end

  describe "start_configs/0" do
    test "returns configs list to be started" do
      expected_list = Config.start_configs()
      configs = Config.__configs__()

      configs
      |> Enum.map(&{Config, &1})
      |> assert_lists_equal(expected_list)
    end
  end

  describe "get_config_data/1" do
    test "returns the config data" do
      data = build(:login_athena)
      assert entry = build(:config_entry, data: data)

      assert {:ok, pid} = Config.start_link(entry)
      assert is_pid(pid)

      assert {:ok, %LoginAthena{}} = Config.get_config_data(entry.id)
    end

    test "returns error when config doesn't exist" do
      assert {:error, :not_found} == Config.get_config_data(:foobarbaz)
    end
  end

  describe "reload_config/1" do
    test "triggers the current started servers to reload their config" do
      entry = build(:config_entry, name: ReloadConfig, reload?: true)

      captured_log =
        capture_log(fn ->
          assert {:ok, pid} = Config.start_link(entry)
          assert is_pid(pid)

          assert {:ok, %LoginAthena{use_web_auth_token: true}} = Config.get_config_data(entry.id)

          :sys.replace_state(pid, fn state = %Entry{} ->
            %{state | path: @updated_config_file}
          end)

          assert :ok == Config.reload_config(entry.type)
        end)

      assert captured_log =~ "Reading file #{@updated_config_file}"
      assert captured_log =~ "Reloading #{entry.type} config"
      assert captured_log =~ "Reading file #{entry.path}"
      refute captured_log =~ "Configs with type server can't be reloaded"

      assert {:ok, %LoginAthena{use_web_auth_token: false}} = Config.get_config_data(entry.id)
    end

    test "logs a warn about configs unable to be reloaded" do
      entry = build(:config_entry, reload?: false)

      captured_log =
        capture_log(fn ->
          assert {:ok, pid} = Config.start_link(entry)
          assert is_pid(pid)

          assert {:ok, %LoginAthena{use_web_auth_token: true}} = Config.get_config_data(entry.id)

          :sys.replace_state(pid, fn state = %Entry{} ->
            %{state | path: @updated_config_file}
          end)

          assert :ok == Config.reload_config(entry.type)
        end)

      refute captured_log =~ "Reading file #{@updated_config_file}"
      refute captured_log =~ "Reloading #{entry.type} config"
      assert captured_log =~ "Reading file #{entry.path}"
      assert captured_log =~ "Configs with type server can't be reloaded"

      assert {:ok, %LoginAthena{use_web_auth_token: true}} = Config.get_config_data(entry.id)
    end
  end
end

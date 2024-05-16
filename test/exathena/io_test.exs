defmodule ExAthena.IOTest do
  use ExAthena.DataCase

  alias ExAthena.Config
  alias ExAthena.IO.{InvalidOptionError, InvalidTypeError}

  @options [:schema, :category, :name, :reload?]

  setup do
    start_supervised!(Config)

    :ok
  end

  test "configuration/0 returns the configuration list" do
    assert %{login_athena: _opts} = Config.configuration()
  end

  test "get/1 returns the given configuration item by id" do
    assert {:ok, keyword} = Config.get(:login_athena)

    assert keyword[:id] == :login_athena
    assert Keyword.has_key?(keyword, :name)
    assert Keyword.has_key?(keyword, :schema)
  end

  test "get/1 returns error when key doesn't exist on configuration map" do
    assert {:error, :not_found} = Config.get(:foo)
  end

  describe "__using__/1" do
    test "throws exception when `configure/1` type is invalid" do
      assert_raise InvalidTypeError, "Expected a valid configuration type, got: foo", fn ->
        defmodule Foo do
          use ExAthena.IO

          configure :foo do
          end
        end
      end
    end

    Enum.each(@options, fn option ->
      @tag option: option
      test "throws exception when #{option} isn't present", %{option: option} do
        options = [name: Foo, schema: Foo, reload?: true, category: :server]
        {_, options} = Keyword.pop!(options, option)

        assert_raise InvalidOptionError,
                     "The given option #{option} wasn't defined in the configuration options",
                     fn ->
                       defmodule Foo do
                         use ExAthena.IO

                         configure :conf do
                           item :foo, options
                         end
                       end
                     end
      end
    end)
  end
end

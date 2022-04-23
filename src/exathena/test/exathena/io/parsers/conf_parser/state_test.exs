defmodule ExAthena.IO.ConfParser.StateTest do
  use ExAthena.DataCase

  alias ExAthena.IO.ConfParser.State

  describe "define_config/3" do
    test "defines a config key with given value" do
      assert %State{result: {:ok, %{"id" => 123_456}}} =
               State.define_config(%State{}, "id", "123456")
    end

    test "defines a boolean value" do
      true_state = %State{result: {:ok, %{"key" => true}}}
      false_state = %State{result: {:ok, %{"key" => false}}}

      assert true_state == State.define_config(%State{}, "key", "yes")
      assert true_state == State.define_config(%State{}, "key", "true")
      assert true_state == State.define_config(%State{}, "key", "on")

      assert false_state == State.define_config(%State{}, "key", "no")
      assert false_state == State.define_config(%State{}, "key", "false")
      assert false_state == State.define_config(%State{}, "key", "off")
    end

    test "defines a decimal value" do
      assert %State{result: {:ok, %{"key" => %Decimal{}}}} =
               State.define_config(%State{}, "key", "10.5")
    end

    test "defines an atom value" do
      assert %State{result: {:ok, %{"key" => :user_id}}} =
               State.define_config(%State{}, "key", "user_id")
    end

    test "defines a list value" do
      assert %State{result: {:ok, %{"key" => ["value", "value2"]}}} =
               State.define_config(%State{}, "key", "value,value2")
    end

    test "appends the imports key with given path" do
      assert %State{imports: ["./foo/bar.conf"]} =
               State.define_config(%State{}, "import", "./foo/bar.conf")
    end

    test "ignores the empty value" do
      assert %State{} == State.define_config(%State{}, "foo", nil)
      assert %State{} == State.define_config(%State{}, "foo", "")
    end

    test "keeps the error even with valid operations" do
      invalid_state = %State{result: {:error, :reason}}

      assert invalid_state == State.define_config(invalid_state, "foo", "bar")
      assert invalid_state == State.define_config(invalid_state, "foo", "baz")
    end
  end
end

defmodule ExAthenaLogger.Sql.AuthenticationLogTest do
  use ExAthenaLogger.DataCase, async: true

  alias ExAthenaLogger.Sql.AuthenticationLog

  describe "changeset/2" do
    test "returns an invalid changeset" do
      refute_changeset AuthenticationLog.changeset(%AuthenticationLog{}, %{})
    end

    test "returns an valid changeset" do
      attrs = LoggerFactory.params_for(:authentication_log)
      assert_changeset AuthenticationLog.changeset(%AuthenticationLog{}, attrs)
    end
  end
end

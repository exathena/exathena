defmodule ExAthenaTest do
  use ExAthena.DataCase

  describe "now/1" do
    test "returns the datetime with default time zone (:utc)" do
      datetime = Timex.now()
      travel_to(datetime)

      assert datetime == ExAthena.now()
    end

    test "returns the datetime with given time zone" do
      timezone = "America/Sao_Paulo"
      datetime = Timex.now(timezone)
      travel_to(datetime)

      assert datetime == ExAthena.now(timezone)
    end
  end
end

defmodule ExAthena.DatabaseFactory do
  @moduledoc false

  @doc false
  defmacro __using__(_) do
    quote do
      def atcommand_factory do
        %ExAthena.Database.AtCommand{
          command: "help",
          aliases: ["h"],
          help: "Show message help"
        }
      end

      def group_factory do
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
    end
  end
end

defmodule ExAthenaLogger do
  @moduledoc """
  The ExAthena Logger context.

  It concentrates all functions to log user
  actions and system changes.
  """

  @doc """
  Handle event from `telemetry`.
  """
  @callback handle_event([atom(), ...], map(), map(), term()) :: any()

  @adapter Application.compile_env(:exathena, :logger_adapter, ExAthenaLogger.Console)

  @events %{
    "exathena-logger-authentication-log" => [:exathena, :authentication, :log]
  }

  @doc """
  Start ExAthena Logger handlers with prefix.
  """
  @spec start_handlers(String.t()) :: :ok
  def start_handlers(prefix \\ "") do
    Enum.reduce_while(@events, :ok, fn {event_name, event_id}, acc ->
      case :telemetry.attach(prefix <> event_name, event_id, &handle_event/4, []) do
        :ok -> {:cont, acc}
        error = {:error, _} -> {:halt, error}
      end
    end)
  end

  @doc """
  Gets all `telemetry` event names with prefix.
  """
  @spec event_names(String.t()) :: list(String.t())
  def event_names(prefix \\ "") do
    @events
    |> Map.keys()
    |> Enum.map(&(prefix <> &1))
  end

  defp handle_event(event, measurements, metadata, config) do
    @adapter.handle_event(event, measurements, metadata, config)
  end
end

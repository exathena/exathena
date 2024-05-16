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

  @adapters Application.compile_env(:exathena, :logger_adapters, [])

  @events %{
    "exathena-logger-authentication-log" => [:exathena, :authentication, :log]
  }

  @doc """
  Start ExAthena Logger handlers with prefix.
  """
  @spec start_handlers(String.t()) :: :ok
  def start_handlers(prefix \\ "") do
    for {name, event} <- @events do
      for mod <- @adapters do
        suffix = mod |> Module.split() |> List.last() |> String.downcase()
        event_name = "#{prefix}-#{name}-#{suffix}"

        :telemetry.attach(event_name, event, &mod.handle_event/4, [])
      end
    end

    :ok
  end

  @doc """
  Gets all `telemetry` event names with prefix.
  """
  @spec event_names(String.t()) :: list(String.t())
  def event_names(prefix \\ "") do
    for {name, _event} <- @events, reduce: [] do
      acc ->
        event_names =
          for mod <- @adapters do
            suffix = mod |> Module.split() |> List.last() |> String.downcase()
            "#{prefix}-#{name}-#{suffix}"
          end

        List.flatten(acc, event_names)
    end
  end
end

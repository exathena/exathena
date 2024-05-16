defmodule ExAthenaLogger.Console do
  @moduledoc """
  The ExAthena Logger adapter for console.
  """
  @behaviour ExAthenaLogger

  require Logger

  @doc """
  Gets the log message from metadata
  """
  @callback get_log_message(map()) :: String.t()

  @doc """
  Build the Logger metadata from event measurements and metadata
  """
  @callback build_metadata(map(), map()) :: map() | keyword()

  @doc """
  Gets the Logger level from metadata
  """
  @callback get_log_type(map()) :: :info | :debug | :error | :warning

  alias ExAthenaLogger.Console.AuthenticationLogger

  @authentication_log_event ~w(exathena authentication log)a

  @impl true
  def handle_event(event, measurements, meta, _config) do
    message = get_log_message(event, meta)
    metadata = build_metadata(event, measurements, meta)

    case get_log_type(event, meta) do
      :info -> Logger.info(message, metadata)
      :debug -> Logger.debug(message, metadata)
      :warning -> Logger.warning(message, metadata)
      :error -> Logger.error(message, metadata)
    end
  end

  defp get_log_message(@authentication_log_event, meta) do
    AuthenticationLogger.get_log_message(meta)
  end

  defp build_metadata(@authentication_log_event, measurements, meta) do
    AuthenticationLogger.build_metadata(measurements, meta)
  end

  defp get_log_type(@authentication_log_event, meta) do
    AuthenticationLogger.get_log_type(meta)
  end
end

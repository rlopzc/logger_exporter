defmodule LoggerExporter.Exporters.Exporter do
  @moduledoc """
  Behaviour that should be implemented by exporters.
  Example implementation in `LoggerExporter.Exporters.LokiExporter`
  """

  alias LoggerExporter.Event

  @doc """
  Headers

  [{"Content-Type", "application/json"}] is added by default
  """
  @callback headers() :: Mint.Types.headers()

  @doc """
  Body to sent to the external service

  The body will be encoded by the json library
  """
  @callback body([Event.t()]) :: term()
end

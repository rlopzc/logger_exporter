defmodule LoggerExporter.ExporterBehavior do
  @moduledoc """
  Behaviour that should be implemented by exporters.
  Example implementation in `LoggerExporter.Exporters.LokiExporter`
  """

  alias LoggerExporter.Event

  @doc """
  Headers
  """
  @callback headers() :: [{String.t(), String.t()}]

  @doc """
  Body to sent to the external service
  """
  @callback body([Event.t()]) :: binary()
end

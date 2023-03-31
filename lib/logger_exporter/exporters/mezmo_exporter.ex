defmodule LoggerExporter.Exporters.MezmoExporter do
  @moduledoc """
  MezmoExporter
  """

  alias LoggerExporter.Event

  @behaviour LoggerExporter.Exporters.Exporter

  @impl true
  def headers do
    []
  end

  @impl true
  def body(events) do
    lines = Enum.map(events, &event_to_log/1)

    %{
      lines: lines
    }
  end

  defp event_to_log(%Event{} = event) do
    %{
      timestamp: System.convert_time_unit(event.timestamp_ns, :nanosecond, :millisecond),
      line: event.log,
      app: event.app_name,
      level: event.level,
      # TODO: support metadata
      meta: ""
    }
  end
end

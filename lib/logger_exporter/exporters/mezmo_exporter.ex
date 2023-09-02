defmodule LoggerExporter.Exporters.MezmoExporter do
  @moduledoc """
  MezmoExporter
  """

  alias LoggerExporter.Event

  @behaviour LoggerExporter.ExporterBehavior

  @impl true
  def headers do
    [{"Content-Type", "application/json"}]
  end

  @impl true
  def body(events) do
    lines = Enum.map(events, &event_to_log/1)

    Jason.encode!(%{lines: lines})
  end

  defp event_to_log(%Event{} = event) do
    timestam_ms = System.convert_time_unit(event.timestamp_ns, :nanosecond, :millisecond)

    %{
      timestamp: timestam_ms,
      line: event.log_line,
      app: event.app_name,
      level: event.level
    }
  end
end

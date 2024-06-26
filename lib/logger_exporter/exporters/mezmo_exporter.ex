defmodule LoggerExporter.Exporters.MezmoExporter do
  @moduledoc """
  MezmoExporter

  https://docs.mezmo.com/log-analysis-api#ingest
  """

  alias LoggerExporter.Event

  @behaviour LoggerExporter.ExporterBehavior

  @impl LoggerExporter.ExporterBehavior
  def headers do
    [{"Content-Type", "application/json"}]
  end

  @impl LoggerExporter.ExporterBehavior
  def body(events) do
    lines = Enum.map(events, &event_to_log/1)

    Jason.encode!(%{lines: lines})
  end

  defp event_to_log(%Event{} = event) do
    timestamp_ms = System.convert_time_unit(event.timestamp_ns, :nanosecond, :millisecond)

    meta =
      case event.metadata |> Map.new() |> Jason.encode() do
        {:ok, meta} -> meta
        {:error, _error} -> ""
      end

    %{
      timestamp: timestamp_ms,
      line: event.log_line,
      app: event.app_name,
      level: event.level,
      meta: meta
    }
  end
end

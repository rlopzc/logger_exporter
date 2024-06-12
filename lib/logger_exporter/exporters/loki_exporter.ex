defmodule LoggerExporter.Exporters.LokiExporter do
  @moduledoc """
  LokiExporter

  https://grafana.com/docs/loki/latest/reference/loki-http-api/#ingest-logs
  """

  alias LoggerExporter.Config
  alias LoggerExporter.Event

  @behaviour LoggerExporter.ExporterBehavior

  @impl LoggerExporter.ExporterBehavior
  def headers do
    [{"Content-Type", "application/json"}]
  end

  @impl LoggerExporter.ExporterBehavior
  def body(events) do
    logs = Enum.map(events, &event_to_log/1)
    {:ok, hostname} = :inet.gethostname()

    Jason.encode!(%{
      streams: [
        %{
          stream: %{
            app: Config.app_name(),
            env: Config.environment_name(),
            hostname: hostname
          },
          values: logs
        }
      ]
    })
  end

  defp event_to_log(%Event{timestamp_ns: timestamp_ns, log_line: log_line, metadata: metadata}) do
    [to_string(timestamp_ns), log_line, format_metadata(metadata)]
  end

  # The JSON object must be a valid JSON object with string keys and string
  # values. The JSON object should not contain any nested object.
  defp format_metadata(metadata) do
    Map.new(metadata, fn {key, val} -> {to_string(key), to_string(val)} end)
  end
end

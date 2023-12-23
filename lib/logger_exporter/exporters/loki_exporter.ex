defmodule LoggerExporter.Exporters.LokiExporter do
  @moduledoc """
  LokiExporter

  https://grafana.com/docs/loki/latest/api/#push-log-entries-to-loki
  """

  alias LoggerExporter.{Config, Event}

  @behaviour LoggerExporter.ExporterBehavior

  @impl LoggerExporter.ExporterBehavior
  def headers do
    [{"Content-Type", "application/json"}]
  end

  @impl LoggerExporter.ExporterBehavior
  def body(events) do
    logs = Enum.map(events, &event_to_log/1)

    Jason.encode!(%{
      streams: [
        %{
          stream: %{
            app: Config.app_name(),
            env: Config.environment_name()
          },
          values: logs
        }
      ]
    })
  end

  defp event_to_log(%Event{timestamp_ns: timestamp_ns, log_line: log_line}) do
    [to_string(timestamp_ns), log_line]
  end
end

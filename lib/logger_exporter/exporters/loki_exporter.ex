defmodule LoggerExporter.Exporters.LokiExporter do
  @moduledoc """
  LokiExporter

  Transforms the events in a struct that Loki understands
  """

  alias LoggerExporter.{Config, Event}

  @behaviour LoggerExporter.Exporters.Exporter

  @impl true
  def headers do
    []
  end

  @impl true
  def body(events) do
    values = Enum.map(events, &event_to_log/1)

    %{
      streams: [
        %{
          stream: %{
            app: Config.app_name(),
            env: Config.environment_name()
          },
          values: values
        }
      ]
    }
  end

  defp event_to_log(%Event{timestamp_ns: timestamp_ns, log_line: log_line}) do
    [to_string(timestamp_ns), log_line]
  end
end

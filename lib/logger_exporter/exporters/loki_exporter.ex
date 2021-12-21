defmodule LoggerExporter.Exporters.LokiExporter do
  alias LoggerExporter.{Config, Event}

  @environment_name Mix.env()

  @behaviour LoggerExporter.Exporter

  def headers do
    []
  end

  def body(events) do
    values = Enum.map(events, &event_to_log/1)

    %{
      streams: [
        %{
          stream: %{app: Config.app_name(), env: env()},
          values: values
        }
      ]
    }
    |> IO.inspect(label: "data to send")
  end

  defp event_to_log(%Event{} = event) do
    [event.timestamp_ns, event.log]
  end

  defp env, do: @environment_name
end

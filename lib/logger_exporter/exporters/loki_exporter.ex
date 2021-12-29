defmodule LoggerExporter.Exporters.LokiExporter do
  alias LoggerExporter.{Config, Event}

  @behaviour LoggerExporter.Exporters.Exporter

  def headers do
    case Config.http_auth() do
      {:basic, user, password} ->
        creds = Base.encode64("#{user}:#{password}")
        [{"Authorization", "Basic #{creds}"}]

      _ ->
        []
    end
  end

  def body(events) do
    values = Enum.map(events, &event_to_log/1)

    %{
      streams: [
        %{
          stream: %{app: Config.app_name(), env: Config.environment_name()},
          values: values
        }
      ]
    }
    |> IO.inspect(label: "data to send")
  end

  defp event_to_log(%Event{} = event) do
    [event.timestamp_ns, event.log]
  end
end

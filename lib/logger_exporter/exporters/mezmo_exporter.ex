defmodule LoggerExporter.Exporters.MezmoExporter do
  @moduledoc """
  MezmoExporter
  """

  alias LoggerExporter.{Config, Event}

  @behaviour LoggerExporter.Exporters.Exporter

  @impl true
  def headers do
    api_key =
      case Config.http_auth() do
        {:api_key, api_key} ->
          api_key

        auth_tuple ->
          raise ArgumentError,
                "#{__MODULE__} doesn't support auth: #{to_string(elem(auth_tuple, 0))}"
      end

    [
      {"apiKey", api_key}
    ]
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
      meta: ""
    }
  end
end

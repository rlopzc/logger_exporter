defmodule LoggerExporter.Telemetry do
  require Logger

  def attach_default_logger do
    events = [
      [:logger_exporter, :batch, :start],
      [:logger_exporter, :batch, :stop],
      [:logger_exporter, :batch, :exception]
    ]

    :telemetry.attach_many(
      "logger-exporter-default-logger",
      events,
      &__MODULE__.handle_event/4,
      []
    )
  end

  def handle_event(
        [:logger_exporter, :batch, :stop],
        _measure,
        %{status: :error, response: response},
        _config
      ) do
    Logger.error(
      "[LoggerExporter] Error. Check the LoggerExporter configuration. Response: #{inspect(response)}"
    )
  end

  def handle_event([:logger_exporter, :batch, _event], _measure, _meta, _config) do
    :ok
  end
end

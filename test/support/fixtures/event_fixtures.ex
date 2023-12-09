defmodule LoggerExporter.EventFixtures do
  @moduledoc """
  Test helpers for creating `LoggerExporter.Event` entities.
  """

  alias LoggerExporter.Event

  def event_fixture(attrs \\ %{}) do
    %Event{
      timestamp_ns: System.os_time(:nanosecond),
      log_line: "Log line",
      level: :info,
      app_name: "logger_exporter_app",
      metadata: [user_id: 123, request_id: "uuid"]
    }
  end
end

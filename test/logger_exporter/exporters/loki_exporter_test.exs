defmodule LoggerExporter.Exporters.LokiExporterTest do
  use ExUnit.Case, async: true

  alias LoggerExporter.Exporters.LokiExporter

  import LoggerExporter.EventFixtures

  test "parses events" do
    events = [event_fixture(), event_fixture()]
  end
end

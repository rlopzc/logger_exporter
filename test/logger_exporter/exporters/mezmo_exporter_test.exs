defmodule LoggerExporter.Exporters.MezmoExporterTest do
  use ExUnit.Case, async: true

  alias LoggerExporter.Exporters.MezmoExporter

  import LoggerExporter.EventFixtures

  describe "headers" do
    test "application/json" do
      assert [{"Content-Type", "application/json"}] == MezmoExporter.headers()
    end
  end

  describe "body" do
    test "parses events and encodes it" do
      events = [
        event_fixture(metadata: [user_id: 1]),
        event_fixture(metadata: [user_id: 2])
      ]

      assert %{
               lines: [
                 %{
                   timestamp: _timestamp1,
                   line: "Log line",
                   app: "logger_exporter_app",
                   level: "info",
                   meta: ~s|{"user_id":1}|
                 },
                 %{
                   timestamp: _timestamp3,
                   line: "Log line",
                   app: "logger_exporter_app",
                   level: "info",
                   meta: ~s|{"user_id":2}|
                 }
               ]
             } = Jason.decode!(MezmoExporter.body(events), keys: :atoms)
    end
  end
end

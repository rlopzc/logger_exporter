defmodule LoggerExporter.Exporters.LokiExporterTest do
  use ExUnit.Case, async: true

  alias LoggerExporter.Exporters.LokiExporter

  import LoggerExporter.EventFixtures

  describe "headers" do
    test "application/json" do
      assert [{"Content-Type", "application/json"}] == LokiExporter.headers()
    end
  end

  describe "body" do
    test "parses events and encodes it" do
      events = [event_fixture(), event_fixture()]

      assert %{
               streams: [
                 %{
                   stream: %{
                     app: "test_app",
                     env: "test"
                   },
                   values: [
                     [_timestamp1, "Log line"],
                     [_timestamp2, "Log line"]
                   ]
                 }
               ]
             } = Jason.decode!(LokiExporter.body(events), keys: :atoms)
    end
  end
end

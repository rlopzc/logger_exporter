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
      events = [
        event_fixture(metadata: [user_id: 1]),
        event_fixture(metadata: [user_id: 2])
      ]

      assert %{
               streams: [
                 %{
                   stream: %{
                     app: "test_app",
                     env: "test",
                     hostname: ~c"192"
                   },
                   values: [
                     [_timestamp1, "Log line", %{user_id: "1"}],
                     [_timestamp2, "Log line", %{user_id: "2"}]
                   ]
                 }
               ]
             } = Jason.decode!(LokiExporter.body(events), keys: :atoms)
    end
  end
end

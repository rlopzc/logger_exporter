defmodule LoggerExporterTest do
  use ExUnit.Case
  doctest LoggerExporter

  test "greets the world" do
    assert LoggerExporter.hello() == :world
  end
end

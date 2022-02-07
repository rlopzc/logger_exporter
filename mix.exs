defmodule LoggerExporter.MixProject do
  use Mix.Project

  @source_url "https://github.com/romariolopezc/logger_exporter"
  @version "0.1.0"

  def project do
    [
      app: :logger_exporter,
      version: @version,
      elixir: "~> 1.12",
      deps: deps(),
      description: "Export your logs to external services.",
      name: "LoggerExporter",
      source_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:finch, "~> 0.8"},
      {:telemetry, "~> 0.4.2 or ~> 1.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "LoggerExporter",
      extras: ["README.md"]
    ]
  end
end

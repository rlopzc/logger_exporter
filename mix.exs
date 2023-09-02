defmodule LoggerExporter.MixProject do
  use Mix.Project

  @source_url "https://github.com/romariolopezc/logger_exporter"
  @version "0.4.3"

  def project do
    [
      app: :logger_exporter,
      version: @version,
      elixir: "~> 1.13",
      deps: deps(),
      description: "Export your logs to the service of your choice.",
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
      {:req, "~> 0.4.0"},
      {:jason, "~> 1.2"},
      {:telemetry, "~> 0.4.2 or ~> 1.0"},
      {:plug, "~> 1.7"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      mantainers: ["Romario López"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "LoggerExporter",
      api_referencee: false,
      source_ref: "#{@version}",
      source_url: @source_url
    ]
  end
end

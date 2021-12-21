defmodule LoggerExporter.Config do
  @doc """
  Get the app name. This will be sent as a label for `LoggerExporter.Exporters.LokiExporter`
  """
  def app_name do
    case Keyword.fetch(get_env(), :app_name) do
      {:ok, app} ->
        app

      :error ->
        raise ArgumentError,
              "invalid :app_name option for LoggerExporter application."
    end
  end

  @doc """
  Get the configured exporter via `config :logger, LoggerExporter, exporter: MyExporter`

  Defaults to `LoggerExporter.Exporters.LokiExporter`
  """
  def exporter do
    Keyword.get(get_env(), :exporter, LokiExporter)
  end

  @doc """
  Get the configured host via `config :logger, LoggerExporter, host: "http://localhost`
  """
  def host do
    case Keyword.fetch(get_env(), :host) do
      {:ok, host} ->
        host

      :error ->
        raise ArgumentError,
              "invalid :host option for LoggerExporter application. " <>
                "Expected an url"
    end
  end

  @doc """
  Get application environment
  """
  def get_env do
    Application.get_env(:logger, LoggerExporter, [])
  end
end

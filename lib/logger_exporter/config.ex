defmodule LoggerExporter.Config do
  @moduledoc false

  def app_name do
    case Keyword.fetch(get_env(), :app_name) do
      {:ok, app} ->
        app

      :error ->
        raise ArgumentError,
              "missing :app_name option for LoggerExporter application. " <>
                "Set :app_name to label the logs."
    end
  end

  def environment_name do
    case Keyword.fetch(get_env(), :environment_name) do
      {:ok, env} ->
        env

      :error ->
        raise ArgumentError,
              "missing :environment_name option for LoggerExporter application. " <>
                "Set :environment_name to label the logs."
    end
  end

  def exporter do
    Keyword.get(get_env(), :exporter, LoggerExporter.Exporters.LokiExporter)
  end

  def host do
    case Keyword.fetch(get_env(), :host) do
      {:ok, host} ->
        host

      :error ->
        raise ArgumentError,
              "MISSING_HOST"

    end
  end

  def get_env do
    Application.get_env(:logger, LoggerExporter, [])
  end

  def url do
    host = host()

    case exporter() do
      LoggerExporter.Exporters.LokiExporter ->
        "#{host}/loki/api/v1/push"

      _ ->
        host
    end
  end

  def batch_every_ms do
    Keyword.get(get_env(), :batch_every_ms, 2_000)
  end

  def http_auth do
    Keyword.get(get_env(), :http_auth)
  end

  def send_to_http do
    Keyword.get(get_env(), :send_to_http, true)
  end
end

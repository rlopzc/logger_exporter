defmodule LoggerExporter.HTTPClientWrapper do
  @moduledoc false

  alias LoggerExporter.{Config, Event, HttpClient}

  require Logger

  @spec batch([Event.t()]) :: :ok | :error
  def batch(events) do
    if Config.send_to_http() do
      send_batch_to_http(events)
    else
      :ok
    end
  end

  defp send_batch_to_http(events) do
    :telemetry.span([:logger_exporter, :batch], %{events: events}, fn ->
      exporter = Config.exporter()

      headers = auth_header() ++ exporter.headers()
      body = exporter.body(events)
      http_response = HttpClient.post(Config.url(), headers, body)

      case http_response do
        {:ok, status, _headers, _body} when status >= 200 and status < 300 ->
          :ok

        {:ok, status, _headers, body} when status == 401 ->
          Logger.error(
            "[LoggerExporter] Exporting logs failed. HTTP Authentication failed. body=#{inspect(body)}"
          )

          :error

        {:ok, status, _headers, body} when status < 500 ->
          Logger.error(
            "[LoggerExporter] Exporting #{length(events)} logs failed. JSON too large or invalid. body=#{inspect(body)}"
          )

          :error

        {:ok, _status, _headers, body} ->
          Logger.error(
            "[LoggerExporter] Exporting #{length(events)} logs failed. Third party service failure. body=#{inspect(body)}"
          )

          :error

        {:error, error} ->
          Logger.error(
            "[LoggerExporter] Exporting #{length(events)} logs failed. #{inspect(error)}"
          )

          :error
      end
    end)
  end

  defp auth_header do
    case Config.http_auth() do
      {:basic, user, password} ->
        creds = Base.encode64("#{user}:#{password}")
        [{"Authorization", "Basic #{creds}"}]

      {:bearer, token} ->
        [{"Authorization", "Bearer #{token}"}]

      {:header, header, value} ->
        [{header, value}]

      _ ->
        []
    end
  end
end

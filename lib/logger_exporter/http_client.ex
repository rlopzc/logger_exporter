defmodule LoggerExporter.HttpClient do
  alias LoggerExporter.Config

  require Logger

  @type status() :: 100..599
  @type headers() :: [{String.t(), String.t()}]
  @type body() :: binary()

  @callback post(url :: String.t(), headers(), body()) ::
              {:ok, status(), headers(), body()} | {:error, term()}

  defp post(url, headers, body) do
    impl().post(url, headers, body)
  end

  defp impl do
    Config.http_client()
  end

  @spec send_batch([Event.t()]) :: :ok | :error
  def send_batch(events) do
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
      http_response = post(Config.url(), headers, body)

      case handle_http_response(http_response, length(events)) do
        :ok ->
          {:ok, %{events: events, status: :ok, response: http_response}}

        :error ->
          {:error, %{events: events, status: :error, response: http_response}}
      end
    end)
  end

  defp handle_http_response(http_response, log_size) do
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
          "[LoggerExporter] Exporting #{log_size} logs failed. JSON too large or invalid. status=#{status} body=#{inspect(body)}"
        )

        :error

      {:ok, _status, _headers, body} ->
        Logger.error(
          "[LoggerExporter] Exporting #{log_size} logs failed. Third party service failure. body=#{inspect(body)}"
        )

        :error

      {:error, error} ->
        Logger.error("[LoggerExporter] Exporting #{log_size} logs failed. #{inspect(error)}")

        :error
    end
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

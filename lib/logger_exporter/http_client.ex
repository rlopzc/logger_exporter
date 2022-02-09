defmodule LoggerExporter.HTTPClient do
  @moduledoc false

  alias LoggerExporter.{Config, Event}

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

      headers =
        exporter.headers()
        |> merge_default_headers()

      body =
        exporter.body(events)
        |> Jason.encode!()

      finch_response =
        Finch.build(:post, Config.url(), headers, body)
        |> Finch.request(LoggerExporterFinch)

      case process_batch_response(finch_response, events) do
        :ok ->
          {:ok, %{events: events, status: :ok, response: finch_response}}

        :error ->
          {:error, %{events: events, status: :error, response: finch_response}}
      end
    end)
  end

  defp process_batch_response(finch_response, events) do
    case finch_response do
      {:ok, %Finch.Response{status: status}} when status < 300 ->
        :ok

      {:ok, %Finch.Response{status: status}} when status == 401 ->
        Logger.error("[LoggerExporter] Exporting logs failed. HTTP Authentication failed")

        :error

      {:ok, %Finch.Response{status: status}} when status < 500 ->
        Logger.error(
          "[LoggerExporter] Exporting #{length(events)} logs failed. JSON too large or invalid"
        )

        :error

      {:ok, %Finch.Response{}} ->
        Logger.error(
          "[LoggerExporter] Exporting #{length(events)} logs failed. External service failure"
        )

        :error

      {:error, err} ->
        Logger.error("[LoggerExporter] Exporting #{length(events)} logs failed. #{inspect(err)}")

        :error
    end
  end

  defp merge_default_headers(headers) do
    [{"Content-Type", "application/json"}] ++
      auth_header() ++
      headers
  end

  defp auth_header do
    case Config.http_auth() do
      {:basic, user, password} ->
        creds = Base.encode64("#{user}:#{password}")
        [{"Authorization", "Basic #{creds}"}]

      _ ->
        []
    end
  end
end

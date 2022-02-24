defmodule LoggerExporter.Loggers.Plug do
  @moduledoc """
  A plug for loggin request information in the format:

      method=POST path=/users params=%{"user" => %{"name" => "Juan"}} status=201 duration=101ms

  To use it, just plug it into the desired module.

      plug plug LoggerExporter.Loggers.Plug, log: :debug

  ## Options

    * `:log` - The log level at which this plug should log its request info.
      Default is `:info`.
      The [list of supported levels](https://hexdocs.pm/logger/Logger.html#module-levels)
      is available in the `Logger` documentation.
  """

  require Logger
  alias Plug.Conn
  @behaviour Plug

  @impl true
  def init(opts) do
    Keyword.get(opts, :log, :info)
  end

  @impl true
  def call(conn, level) do
    start_time = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      Logger.log(level, fn ->
        stop_time = System.monotonic_time()
        time_us = System.convert_time_unit(stop_time - start_time, :native, :microsecond)
        time_ms = div(time_us, 1000)

        params =
          case Jason.encode(conn.params) do
            {:ok, json} -> json
            _ -> inspect(conn.params)
          end

        "method=#{conn.method} path=#{conn.request_path} params=#{params} status=#{conn.status} duration=#{time_ms}ms"
      end)

      conn
    end)
  end
end

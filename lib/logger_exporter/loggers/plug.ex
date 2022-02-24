defmodule LoggerExporter.Loggers.Plug do
  @moduledoc """
  A plug for logging request information in the format:

      method=POST path=/users params=%{"user" => %{"name" => "Juan"}} status=201 duration=101ms

  To use it, just plug it into the desired module.

      plug LoggerExporter.Loggers.Plug,
        log: :debug,
        filter_parameters_fn: &Phoenix.Logger.filter_values/1

  ## Options

    * `:log` - The log level at which this plug should log its request info.
      Default is `:info`.
      The [list of supported levels](https://hexdocs.pm/logger/Logger.html#module-levels)
      is available in the `Logger` documentation.
    * `:filter_parameters_fn` - The Function to call with conn.params. Filter
      params that doesn't need to be logged i.e. {"password": "[FILTERED]"}.
  """

  require Logger
  alias Plug.Conn
  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, opts) do
    level = Keyword.get(opts, :log, :info)
    filter_parameters_fn = Keyword.get(opts, :filter_parameters_fn, & &1)

    start_time = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      filtered_params = filter_parameters_fn.(conn.params)

      params =
        case Jason.encode(filtered_params) do
          {:ok, json} -> json
          _ -> inspect(filtered_params)
        end

      Logger.log(level, fn ->
        stop_time = System.monotonic_time()
        time_us = System.convert_time_unit(stop_time - start_time, :native, :microsecond)
        time_ms = div(time_us, 1000)

        "method=#{conn.method} path=#{conn.request_path} params=#{params} status=#{conn.status} duration=#{time_ms}ms"
      end)

      conn
    end)
  end
end

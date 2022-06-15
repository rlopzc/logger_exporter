defmodule LoggerExporter.Loggers.Plug do
  @moduledoc """
  A plug for logging request information in the format:

      method=POST path=/users params=%{"user" => %{"name" => "Juan"}} status=201 duration=101ms

  To use it, just plug it into the desired module.

      plug LoggerExporter.Loggers.Plug,
        log: :debug,
        filter_parameters_fn: &Phoenix.Logger.filter_values/1

  ## Options

    * `:log` - The log level at which this plug should log its request information.
      Default is `:info`.
        * Configure log level. The [list of supported levels](https://hexdocs.pm/logger/Logger.html#module-levels)
      is available in the `Logger` documentation.
        * Configure log level dynamically: `plug LoggerExporter.Logger.Plug, log: {Mod, Fun, Args}`
    * `:filter_parameters_fn` - The Function to call with conn.params. Filter
      params that doesn't need to be logged i.e. {"password": "[FILTERED]"}.

  ## Dynamic log level

    In some cases you may wish to set the log level dynamically
    on a per-request basis. To do so, set the `:log` option to
    a tuple, `{Mod, Fun, Args}`. The `Plug.Conn.t()` for the
    request will be prepended to the provided list of arguments.

    When invoked, your function must return a
    [`Logger.level()`](`t:Logger.level()/0`) or `false` to
    disable logging for the request.

    For example, in your Endpoint you might do something like this:

          # lib/my_app_web/endpoint.ex
          plug LoggerExporter.Loggers.Plug,
            log: {__MODULE__, :log_level, []}

          # Disables logging for routes like /health_check
          def log_level(%{path_info: ["health_check"]}), do: false
          def log_level(_), do: :info
  """

  require Logger
  alias Plug.Conn
  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, opts) do
    filter_parameters_fn = Keyword.get(opts, :filter_parameters_fn, & &1)

    start_time = System.monotonic_time()

    Conn.register_before_send(conn, fn conn ->
      filtered_params = filter_parameters_fn.(conn.params)

      params =
        case Jason.encode(filtered_params) do
          {:ok, json} -> json
          _ -> inspect(filtered_params)
        end

      case log_level(Keyword.get(opts, :log), conn) do
        false ->
          :ok

        level ->
          Logger.log(level, fn ->
            stop_time = System.monotonic_time()
            time_us = System.convert_time_unit(stop_time - start_time, :native, :microsecond)
            time_ms = div(time_us, 1000)

            "method=#{conn.method} path=#{conn.request_path} params=#{params} status=#{conn.status} duration=#{time_ms}ms"
          end)
      end

      conn
    end)
  end

  defp log_level(nil, _conn), do: :info
  defp log_level(level, _conn) when is_atom(level), do: level

  defp log_level({mod, fun, args}, conn) when is_atom(mod) and is_atom(fun) and is_list(args) do
    apply(mod, fun, [conn | args])
  end
end

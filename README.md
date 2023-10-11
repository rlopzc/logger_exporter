# LoggerExporter

Export your logs to the service of your choice.

I created this library because I wanted to export logs to a different service in
Heroku. There is no simple way to export your logs.

## Supported exporters:
- Loki
- Mezmo (LogDNA)

Implement your own exporter using `LoggerExporter.Exporters.Exporter` behaviour.

## Supported formatters:
- Basic. By default, it will read your logger `:console` format configuration.
  Example:
  ```elixir
  config :logger, :console, format: "$time $message"
  ```
  Defaults to `$time $metadata[$level] $message`

Implement your own formatter using `LoggerExporter.Formatters.Formatter` behaviour.

## Plug Logger

A plug for logging request information. It will log the method, path, params,
status and duration.

You can add it to your MyApp.Endpoint:
```elixir
  # Log level defaults to :info
  plug LoggerExporter.Loggers.Plug

  # Dynamic log
  plug LoggerExporter.Loggers.Plug, log: {__MODULE__, :log_level, []}

  # Disables logging for routes like /health_check
  def log_level(%{path_info: ["health_check"]}), do: false
  def log_level(_), do: :info
```

## Installation

Add `logger_exporter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logger_exporter, "~> 0.4.0"}
  ]
end
```

## Configuration

By default, the timestamp sent for each log to the external service is in UTC: `System.os_time(:nanosecond)`

| option           | description                                                                                                   | default                                    |
|------------------|---------------------------------------------------------------------------------------------------------------|--------------------------------------------|
| level            | The logger level to report.                                                                                   | `:info`                                    |
| formatter        | Allows the selection of a formatter implementation.                                                           | `LoggerExporter.Formatters.BasicFormatter` |
| metadata         | Metadata to log.                                                                                              | `[]`                                       |
| exporter         | Allows selection of a exporter implementation.                                                                | `LoggerExporter.Exporters.LokiExporter`    |
| host             | The host of the service without the path. The path is inferred by the exporter.                               | No default. Required                       |
| app_name         | The name of the app to use as label.                                                                          | No default. Required                       |
| environment_name | The name of the app to use as label.                                                                          | No default. Required                       |
| http_client      | Allows the selection of the HTTP client.                                                                      | `LoggerExporter.HttpClient.ReqClient`     |
| send_to_http     | If set to false, the library will not make any actual API calls. This is useful for test or dev environments. | `true`                                     |
| http_auth        | See below for configuration                                                                                   | No default                                 |


### HTPP Auth

Supported authentication methods:
- Basic
- Bearer
- Custom

| auth     | examples                                   | result                                           |
| -------- | ------------------------------------------ | ------------------------------------------------ |
| basic    | `{:basic, "user", "pxIsldPlwty"}`          | `"Authorization: Basic CshL2XlkX57cww=="`        |
| bearer   | `{:bearer, "WmRUuBOnTjDwP6jo3bno"}`        | `"Authorization: Bearer WmRUuBOnTjDwP6jo3bno"`   |
| custom   | `{:header, "apiKey", "dAWRQQkZCc2A=="}`    | `"apiKey: dAWRQQkZCc2A=="`                       |

## Usage in Phoenix

1.  Add the following to deps section of your mix.exs: `{:logger_exporter, "~> 0.4.0"}`
    and then `mix deps.get`

2.  Add `LoggerExporter.Backend` to your logger's backends configuration

    ```
    config :logger,
      backends: [:console, LoggerExporter.Backend]
    ```

3.  Add config related to the exporter and other fields.
    ie. for `LokiExporter`

    ```elixir
    config :logger, LoggerExporter,
      host: "http://localhost:3100",
      app_name: "my_app",
      environment_name: config_env(),
      http_auth: {:basic, System.fetch_env!("LOKI_USER"), System.fetch_env!("LOKI_PASSWORD")},
      metadata: [:request_id]
    ```

4.  Start the LoggerExporter GenServer in the supervised children list.
    In `application.ex` add to the children list:

    ```elixir
    children [
      ...
      LoggerExporter
    ]
    ```
5. (Optional) Add custom Plug logger.
  In `MyApp.Endpoint` add the plug after `Plug.Parsers`.
  If you see duplicate logs, remove `Plug.Telemetry` from your endpoint.

    ```elixir
    plug Plug.Parsers,
      ...

    plug LoggerExporter.Loggers.Plug
    ```

## JSON Formatter Example

If you want to log in JSON format, you can use the formatter of another library:
[logger_json](https://github.com/Nebo15/logger_json)

You need to implement the following formatter using the `LoggerExporter.Formatters.Formatter` behaviour.

```elixir
defmodule MyFormatter do
  @behaviour LoggerExporter.Formatters.Formatter

  alias LoggerJSON.Formatters.BasicLogger

  @impl true
  def format_event(level, msg, ts, md, md_keys) do
    BasicLogger.format_event(level, msg, ts, md, md_keys, [])
    |> Jason.encode!()
  end
end
```

Then, configure it like this:
```elixir
config :logger, LoggerExporter,
  formatter: MyFormatter
```

Tada! You have JSON logs!

## Telemetry

Telemetry integration for logging and error reporting.

There is a default logger for you to attach. It logs when the `status` is `:error`

In your `application.ex`

```elixir
:ok = LoggerExporter.Telemetry.attach_default_logger()
```

### HTTP Post batch events

LoggerExporter emits the following events for processing each batch (sending it through http)

- `[:logger_exporter, :batch, :start]` -- starting to process the events
- `[:logger_exporter, :batch, :stop]` -- after the events is processed
- `[:logger_exporter, :batch, :exception]` -- after the events are processed

The following chart shows which metadata you can expect for each event:

| event        | measures       | metadata                               |
| ------------ | -------------- | ---------                              |
| `:start`     | `:system_time` | `:events`                              |
| `:stop`      | `:duration`    | `:events, :status, :response`          |
| `:exception` | `:duration`    | `:events, :kind, :reason, :stacktrace` |

Metadata
* `:events` - the list of `LoggerExporter.Event` processed
* `:status` - either `:ok` or `:error`
* `:response` - information of the response. Is a `Finch.Response` struct

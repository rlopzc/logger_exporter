# LoggerExporter

Export your logs to the service of your choice.

I created this library because I wanted to export logs to a different service in
Heroku. There is no simple way to export your logs.

## Supported exporters:
- Loki

Implement your own exporter using `LoggerExporter.Exporters.Exporter` behaviour.

## Supported formatters:
- Basic

Implement your own formatter using `LoggerExporter.Formatters.Formatter` behaviour.

## Plug Logger

A plug for logging request information. It will log the method, path, params,
status and duration.

You can add it to your MyApp.Endpoint:
```elixir
  plug LoggerExporter.Loggers.Plug
```

## Installation

Add `logger_exporter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:logger_exporter, "~> 0.1.0"}
  ]
end
```

## Configuration

By default, the timestamp sent for each log to the external service is in utc: `System.os_time(:nanosecond)`

- `config :logger, LoggerExporter, :level`. The logger level to report.
- `config :logger, LoggerExporter, :formatter`. Allows the selection of a formatter implementation. Defaults to `LoggerExporter.Formatters.BasicFormatter`
- `config :logger, LoggerExporter, :metadata`. Metadata to log. Defaults to `[]`
- `config :logger, LoggerExporter, :exporter`. Allows selection of a exporter implementation. Defaults to `LoggerExporter.Exporters.LokiExporter`
- `config :logger, LoggerExporter, :batch_every_ms`. The time (in ms) between every batch request. Default value is 2000 (2 seconds)
- `config :logger, LoggerExporter, :host`. The host of the service without the path. The path is inferred by the exporter. Required
- `config :logger, LoggerExporter, :app_name`. The name of the app to use as label for `Loki`. Required if using `LokiExporter`
- `config :logger, LoggerExporter, :environment_name`. The name of the environment to use as label for `Loki`. Required if using `LokiExporter`
- `config :logger, :send_to_http` If set to false, the library will not make any actual API calls. This is useful for test or dev environments. Default value is true
- `config :logger, LoggerExporter, :http_auth`. See below

### HTPP Auth

Supported authentication methods:
- Basic:

  ```elixir
  config :logger, LoggerExporter,
    host: "https://logs-prod.grafana.net",
    http_auth: {:basic, System.fetch_env!("USER"), System.fetch_env!("PASSWORD")}
  ```

## Usage in Phoenix

1.  Add the following to deps section of your mix.exs: `{:logger_exporter, "~> 0.1.0"}`
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
      environment_name: Mix.env(),
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

## JSON Formatter

If you want to log in JSON format, you can use the formatter of another library:
[logger_json](https://github.com/Nebo15/logger_json)

You can configure it like this:
```elixir
config :logger, LoggerExporter,
  formatter: LoggerJSON.Formatters.BasicLogger
```

And it will work out of the box :)

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

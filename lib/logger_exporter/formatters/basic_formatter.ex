defmodule LoggerExporter.Formatters.BasicFormatter do
  @moduledoc """
  Basic formatter.

  If there is no `:logger -> :console -> :format`, it sets the format to: `@default_format`
  """
  @behaviour LoggerExporter.FormatterBehavior

  @default_format "$time $metadata[$level] $message"

  @impl true
  def format_event(level, msg, timestamp, log_metadata, metadata_keys) do
    get_configured_formatter()
    |> Logger.Formatter.compile()
    |> Logger.Formatter.format(
      level,
      msg,
      timestamp,
      LoggerExporter.take_metadata(log_metadata, metadata_keys)
    )
    |> IO.chardata_to_string()
  end

  defp get_configured_formatter do
    (Application.get_env(:console, :logger) || [])
    |> Keyword.get(:format, @default_format)
  end
end

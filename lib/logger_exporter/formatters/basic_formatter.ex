defmodule LoggerExporter.Formatters.BasicFormatter do
  @moduledoc """
  Basic formatter.

  It formats the log with: "$time [$level] $message $metadata"
  """
  @behaviour LoggerExporter.Formatters.Formatter

  @impl true
  def format_event(level, msg, timestamp, log_metada, metadata_keys) do
    "$time [$level] $message $metadata"
    |> Logger.Formatter.compile()
    |> Logger.Formatter.format(
      level,
      msg,
      timestamp,
      LoggerExporter.take_metadata(log_metada, metadata_keys)
    )
    |> IO.chardata_to_string()
  end
end

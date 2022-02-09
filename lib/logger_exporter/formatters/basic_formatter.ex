defmodule LoggerExporter.Formatters.BasicFormatter do
  @moduledoc """
  Basic formatter.

  It formats the log with: "$time [$level] $message $metadata"
  """
  @behaviour LoggerExporter.Formatters.Formatter

  @impl true
  def format_event(level, msg, ts, md, md_keys) do
    "$time [$level] $message $metadata"
    |> Logger.Formatter.compile()
    |> Logger.Formatter.format(level, msg, ts, LoggerExporter.take_metadata(md, md_keys))
    |> IO.chardata_to_string()
  end
end

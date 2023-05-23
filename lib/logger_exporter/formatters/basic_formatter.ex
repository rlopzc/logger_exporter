defmodule LoggerExporter.Formatters.BasicFormatter do
  @moduledoc """
  Basic formatter.

  If there is no `:logger -> :console -> :format`, it sets the format to: "$time $metadata[$level] $message"
  """
  @behaviour LoggerExporter.Formatters.Formatter

  @impl true
  def format_event(level, msg, timestamp, log_metada, metadata_keys) do
    default_formatter()
    |> Logger.Formatter.compile()
    |> Logger.Formatter.format(
      level,
      msg,
      timestamp,
      LoggerExporter.take_metadata(log_metada, metadata_keys)
    )
    |> IO.chardata_to_string()
  end

  defp default_formatter do
    :logger
    |> Application.get_env(:console)
    |> Keyword.get(:format, "$time $metadata[$level] $message")
  end
end

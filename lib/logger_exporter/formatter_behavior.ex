defmodule LoggerExporter.FormatterBehavior do
  @moduledoc """
  Behaviour that should be implemented by log formatters.
  Example implementation in `LoggerExporter.Formatters.BasicLogger`
  """

  @doc """
  Format event callback.
  """
  @callback format_event(
              level :: Logger.level(),
              msg :: Logger.message(),
              timestamp :: Logger.Formatter.time(),
              log_metadata :: keyword(),
              metadata_keys :: [atom] | :all
            ) :: String.t()
end

defmodule LoggerExporter.Formatters.Formatter do
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
              ts :: Logger.Formatter.time(),
              md :: keyword(),
              md_keys :: [atom] | :all
            ) :: String.t()
end

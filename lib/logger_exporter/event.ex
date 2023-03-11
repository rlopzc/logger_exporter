defmodule LoggerExporter.Event do
  @moduledoc """
  Event struct that holds the formatted log
  """
  @enforce_keys [:timestamp_ns, :log, :level, :app_name, :metadata]
  defstruct [:timestamp_ns, :log, :level, :app_name, :metadata]

  @type t :: %__MODULE__{
          timestamp_ns: non_neg_integer(),
          log: String.t(),
          level: Logger.level(),
          app_name: String.t(),
          metadata: Keyword.t()
        }
end

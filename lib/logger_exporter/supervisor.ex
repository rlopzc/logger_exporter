defmodule LoggerExporter.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(logger_exporter, opts) do
    name = Keyword.get(opts, :name, logger_exporter)
    sup_opts = if name, do: [name: name], else: []
    Supervisor.start_link(__MODULE__, opts, sup_opts)
  end

  @impl true
  def init(_opts) do
    children = [
      LoggerExporter.Batcher,
      {Finch, name: LoggerExporterFinch}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

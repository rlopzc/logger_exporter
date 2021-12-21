defmodule LoggerExporter.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LoggerExporter.Batcher,
      {Finch, name: FinchHTTPClient}
    ]

    opts = [strategy: :one_for_one, name: LoggerExporter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

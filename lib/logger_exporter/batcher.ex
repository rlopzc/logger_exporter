defmodule LoggerExporter.Batcher do
  use GenServer

  alias LoggerExporter.{Event, HTTPClient}

  def start_link(_) do
    GenServer.start_link(__MODULE__, :queue.new(), name: __MODULE__)
  end

  # Client

  @impl true
  def init(queue) do
    schedule_batch_send()
    {:ok, queue}
  end

  @doc """
  Enqueue events to the Batcher
  Events will be processed and exported to the service
  """
  @spec enqueue(Event.t()) :: :ok
  def enqueue(event) do
    GenServer.cast(__MODULE__, {:enqueue, event})
  end

  # GenServer

  @impl true
  def handle_cast({:enqueue, event}, queue) do
    {:noreply, :queue.in(event, queue)}
  end

  @impl true
  def handle_info(:process_batch, queue) do
    items = :queue.to_list(queue)

    if length(items) > 0, do: HTTPClient.batch(items)

    schedule_batch_send()
    {:noreply, :queue.new()}
  end

  # Helpers

  defp schedule_batch_send do
    Process.send_after(self(), :process_batch, 5000)
  end
end

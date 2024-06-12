defmodule LoggerExporter.Batcher do
  @moduledoc """
  GenServer that batches the events in a `:queue`

  Every N seconds, it sends the batch through the configured HTTPClient.
  """
  use GenServer

  alias LoggerExporter.{Config, Event, HttpClient}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :queue.new(), name: __MODULE__)
  end

  # Client

  @impl GenServer
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

  @spec get_queue() :: [Event.t()]
  def get_queue do
    GenServer.call(__MODULE__, :get_queue)
  end

  # GenServer

  @impl GenServer
  def handle_cast({:enqueue, event}, queue) do
    {:noreply, :queue.in(event, queue)}
  end

  @impl GenServer
  def handle_call(:get_queue, _from, queue) do
    {:reply, :queue.to_list(queue), queue}
  end

  @impl GenServer
  def handle_info(:process_batch, queue) do
    items = :queue.to_list(queue)

    if items != [], do: HttpClient.send_batch(items)

    schedule_batch_send()
    {:noreply, :queue.new()}
  end

  # Helpers

  defp schedule_batch_send do
    Process.send_after(self(), :process_batch, Config.batch_every_ms())
  end
end

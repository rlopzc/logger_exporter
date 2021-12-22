defmodule LoggerExporter do
  # TODO: How to disable it in test env? Manage it via Config?
  # Use like sentry included environments?

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :supervisor
    }
  end

  def start_link(opts \\ []) do
    LoggerExporter.Supervisor.start_link(__MODULE__, opts)
  end

  @doc """
  Take specified keys from the metadata
  """
  @spec take_metadata(keyword(), :all | [atom()]) :: keyword()
  def take_metadata(metadata, :all), do: metadata

  def take_metadata(metadata, keys) do
    Enum.reduce(keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error -> acc
      end
    end)
  end
end

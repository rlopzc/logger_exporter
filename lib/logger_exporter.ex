defmodule LoggerExporter do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(0)
  @external_resource "README.md"

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
  def take_metadata(log_metadata, :all), do: log_metadata

  def take_metadata(log_metadata, keys) do
    Enum.reduce(keys, [], fn key, acc ->
      case Keyword.fetch(log_metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error -> acc
      end
    end)
  end
end

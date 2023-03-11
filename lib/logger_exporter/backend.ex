defmodule LoggerExporter.Backend do
  @moduledoc """
  LoggerExporter Backend.

  Used when configuring the `Logger` :backends
  """

  @behaviour :gen_event

  alias LoggerExporter.Formatters
  alias LoggerExporter.{Batcher, Config, Event}

  require Logger

  defstruct [:level, :metadata_keys, :formatter, :app_name]

  @impl true
  def init(__MODULE__) do
    config = Config.get_env()

    {:ok, init(config, %__MODULE__{})}
  end

  def init({__MODULE__, opts}) when is_list(opts) do
    config = configure_merge(Config.get_env(), opts)

    {:ok, init(config, %__MODULE__{})}
  end

  @impl true
  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  @impl true
  def handle_event({level, _gl, {Logger, message, timestamp, metadata}}, state) do
    %{level: log_level} = state

    if meet_level?(level, log_level) do
      log_event(level, message, timestamp, metadata, state)
    end

    {:ok, state}
  end

  @impl true
  def handle_event(:flush, state) do
    {:ok, state}
  end

  @impl true
  def handle_event(_, state) do
    {:ok, state}
  end

  ## Helpers

  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp init(config, state) do
    level = Keyword.get(config, :level, :info)
    formatter = Keyword.get(config, :formatter, Formatters.BasicFormatter)
    metadata_keys = Keyword.get(config, :metadata, []) |> configure_metadata()
    app_name = Config.app_name()

    %{
      state
      | level: level,
        formatter: formatter,
        metadata_keys: metadata_keys,
        app_name: app_name
    }
  end

  defp configure_metadata(:all), do: :all
  defp configure_metadata(metadata), do: Enum.reverse(metadata)

  defp configure_merge(env, options), do: Keyword.merge(env, options, fn _key, _v1, v2 -> v2 end)

  defp configure(options, state) do
    config = configure_merge(Config.get_env(), options)

    Application.put_env(:logger, __MODULE__, config)
    init(config, state)
  end

  defp log_event(level, msg, timestamp, metadata, state) do
    event = format_event(level, msg, timestamp, metadata, state)

    Batcher.enqueue(event)
  end

  defp format_event(level, msg, timestamp, metadata, state) do
    %{formatter: formatter, metadata_keys: metadata_keys, app_name: app_name} = state

    log = formatter.format_event(level, msg, timestamp, metadata, metadata_keys)

    %Event{
      timestamp_ns: System.os_time(:nanosecond),
      log: log,
      level: level,
      app_name: app_name,
      metadata: LoggerExporter.take_metadata(metadata, metadata_keys)
    }
  end
end

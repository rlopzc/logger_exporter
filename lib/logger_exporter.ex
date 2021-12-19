defmodule LoggerExporter do
  @behaviour :gen_event

  alias LoggerExporter.Batcher

  require Logger

  # TODO: How to disable it in test env? Manage it via Config?
  # Use like sentry included environments?

  defstruct level: nil, metadata: nil, formatter: nil

  @impl true
  def init(__MODULE__) do
    config = get_env()

    {:ok, init(config, %__MODULE__{})}
  end

  def init({__MODULE__, opts}) when is_list(opts) do
    config = configure_merge(get_env(), opts)
    {:ok, init(config, %__MODULE__{})}
  end

  @impl true
  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  @impl true
  def handle_event({level, _gl, {Logger, message, timestamp, metadata}}, state) do
    %{level: log_level} = state

    cond do
      not meet_level?(level, log_level) ->
        {:ok, state}

      true ->
        log_event(level, message, timestamp, metadata, state)
        {:ok, state}
    end
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

  defp get_env do
    Application.get_env(:logger, __MODULE__)
  end

  defp meet_level?(_lvl, nil), do: true

  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp init(config, state) do
    level = Keyword.get(config, :level, :info)
    formatter = Keyword.get(config, :formatter)
    metadata = Keyword.get(config, :metadata, []) |> configure_metadata()

    %{
      state
      | level: level,
        formatter: formatter,
        metadata: metadata
    }
  end

  defp configure_metadata(:all), do: :all
  defp configure_metadata(metadata), do: Enum.reverse(metadata)

  defp configure_merge(env, options), do: Keyword.merge(env, options, fn _key, _v1, v2 -> v2 end)

  defp configure(options, state) do
    config = configure_merge(get_env(), options)

    Application.put_env(:logger, __MODULE__, config)
    init(config, state)
  end

  defp log_event(level, msg, ts, md, state) do
    event = format_event(level, msg, ts, md, state)

    Batcher.enqueue(ts, event)
  end

  defp format_event(level, msg, ts, md, state) do
    # TODO: Use formatter and call format_event
    %{formatter: _formatter, metadata: md_keys} = state

    # unless formatter do
    #   raise ArgumentError,
    #         "invalid :formatter option for :logger_exporter application. " <>
    #           "Expected module name that implements LoggerExporter.Formatter behaviour, "
    # end

    "$time [$level] $message $metadata\n"
    |> Logger.Formatter.compile()
    |> Logger.Formatter.format(level, msg, ts, take_metadata(md, md_keys))
  end

  defp take_metadata(metadata, :all), do: metadata

  defp take_metadata(metadata, keys) do
    Enum.reduce(keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error -> acc
      end
    end)
  end
end

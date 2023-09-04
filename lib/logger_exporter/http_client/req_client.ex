defmodule LoggerExporter.HttpClient.ReqClient do
  @moduledoc """
  HTTP Client implementing `LoggerExporter.HttpClient` using `Req`.

  https://hexdocs.pm/req/Req.html
  """
  @behaviour LoggerExporter.HttpClient

  def post(url, headers, body) do
    normalized_headers = normalize_headers(headers)

    case Req.post(url, headers: normalized_headers, body: body) do
      {:ok, %Req.Response{status: status, headers: headers, body: body}} ->
        denormalized_headers = denormalize_headers(headers)
        {:ok, status, denormalized_headers, body}

      {:error, exception} ->
        {:error, exception}
    end
  end

  # Change `LoggerExporter.HttpClient.headers()` list to map
  defp normalize_headers(headers) do
    Enum.reduce(headers, %{}, fn {header, value}, map ->
      header = String.downcase(header)

      Map.update(map, header, [value], &[value | &1])
    end)
  end

  # Deduplicate headers and return the last value of the headers list
  defp denormalize_headers(headers) do
    Enum.reduce(headers, [], fn {header, values}, list ->
      [{header, List.last(values)} | list]
    end)
    |> Enum.reverse()
  end
end

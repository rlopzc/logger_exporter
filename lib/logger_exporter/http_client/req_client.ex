defmodule LoggerExporter.HttpClient.ReqClient do
  @moduledoc """
  HTTP Client implementing `LoggerExporter.HttpClient` using `Req`.
  """
  @behaviour LoggerExporter.HttpClient

  def post(url, headers, body) do
    case Req.post(url, headers: headers, body: body) do
      {:ok, %Req.Response{status: status, headers: headers, body: body}} ->
        headers = Enum.into(headers, [])
        {:ok, status, headers, body}

      {:error, exception} ->
        {:error, exception}
    end
  end
end

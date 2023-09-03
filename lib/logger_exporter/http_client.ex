defmodule LoggerExporter.HttpClient do
  alias LoggerExporter.Config

  @type status() :: 100..599
  @type headers() :: [{String.t(), String.t()}]
  @type body() :: binary()

  @callback post(url :: String.t(), headers(), body()) ::
              {:ok, status(), headers(), body()} | {:error, term()}

  def post(url, headers, body) do
    impl().post(url, headers, body)
  end

  defp impl do
    Config.http_client()
  end
end

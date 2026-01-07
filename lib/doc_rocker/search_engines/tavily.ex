defmodule DocRocker.SearchEngines.Tavily do
  @moduledoc false

  require Logger

  alias DocRocker.Config
  alias DocRocker.HttpClient

  @api_url "https://api.tavily.com/search"
  @extract_api_url "https://api.tavily.com/extract"

  def search(query, picked_domains) do
    api_key = Config.tavily_api_key()

    if is_nil(api_key) or api_key == "" do
      {:error, "Tavily API key is not set"}
    else
      is_worldwide = Enum.any?(picked_domains, &(&1 == "*"))

      request_body =
        %{query: query, include_answer: "advanced"}
        |> maybe_include_domains(is_worldwide, picked_domains)

      headers = [
        {"accept", "application/json"},
        {"content-type", "application/json"},
        {"authorization", "Bearer #{api_key}"}
      ]

      case HttpClient.post_json(@api_url, headers, request_body) do
        {:ok, response_body} ->
          answer = Map.get(response_body, "answer")

          if is_binary(answer) do
            citations =
              response_body
              |> Map.get("results", [])
              |> Enum.map(&Map.get(&1, "url"))

            {:ok,
             %{
               answer: "## Doc-Rocker Search-Agent Result\n" <> answer,
               citations: citations
             }}
          else
            {:error, "Invalid response from Tavily API"}
          end

        {:error, {status, response_body}} ->
          error_text = format_error_body(response_body)
          {:error, "Tavily API error: #{status} #{error_text}"}

        {:error, exception} ->
          Logger.warning("Tavily request failed: #{Exception.message(exception)}")
          {:error, "Tavily API error: #{Exception.message(exception)}"}
      end
    end
  end

  def extract(url) do
    api_key = Config.tavily_api_key()

    if is_nil(api_key) or api_key == "" do
      {:error, "Tavily API key is not set"}
    else
      request_body = %{
        urls: url,
        include_images: false,
        extract_depth: "basic"
      }

      headers = [
        {"accept", "application/json"},
        {"content-type", "application/json"},
        {"authorization", "Bearer #{api_key}"}
      ]

      case HttpClient.post_json(@extract_api_url, headers, request_body) do
        {:ok, response_body} ->
          results = Map.get(response_body, "results", [])

          case results do
            [%{"raw_content" => raw_content} | _] ->
              {:ok, raw_content}

            _ ->
              {:error, "No content extracted from the URL"}
          end

        {:error, {status, response_body}} ->
          error_text = format_error_body(response_body)
          {:error, "Tavily Extract API error: #{status} #{error_text}"}

        {:error, exception} ->
          Logger.warning("Tavily extract failed: #{Exception.message(exception)}")
          {:error, "Tavily Extract API error: #{Exception.message(exception)}"}
      end
    end
  end

  defp maybe_include_domains(request_body, true, _picked_domains), do: request_body

  defp maybe_include_domains(request_body, false, picked_domains) do
    Map.put(request_body, :include_domains, picked_domains)
  end

  defp format_error_body(body) when is_binary(body), do: body

  defp format_error_body(body) do
    case Jason.encode(body) do
      {:ok, encoded} -> encoded
      _ -> inspect(body)
    end
  end
end

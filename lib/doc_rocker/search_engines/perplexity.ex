defmodule DocRocker.SearchEngines.Perplexity do
  @moduledoc false

  require Logger

  alias DocRocker.Config
  alias DocRocker.HttpClient

  @api_url "https://api.perplexity.ai/chat/completions"

  def search(query, picked_domains) do
    api_key = Config.perplexity_api_key()

    if is_nil(api_key) or api_key == "" do
      {:error, "Perplexity API key is not set"}
    else
      model = Config.perplexity_model()
      is_worldwide = Enum.any?(picked_domains, &(&1 == "*"))

      system_message =
        if is_worldwide do
          "You are a helpful assistant that answers questions about any topic. Be precise and concise."
        else
          "You are a helpful assistant that answers questions about documentation. Please only use information from these domains: #{Enum.join(picked_domains, ", ")}. Be precise and concise."
        end

      request_body = %{
        model: model,
        messages: [
          %{role: "system", content: system_message},
          %{role: "user", content: query}
        ]
      }

      request_body =
        if is_worldwide do
          request_body
        else
          Map.put(request_body, :search_domain_filter, picked_domains)
        end

      headers = [
        {"accept", "application/json"},
        {"content-type", "application/json"},
        {"authorization", "Bearer #{api_key}"}
      ]

      case HttpClient.post_json(@api_url, headers, request_body) do
        {:ok, response_body} ->
          content = get_in(response_body, ["choices", Access.at(0), "message", "content"])

          if is_binary(content) do
            citations = Map.get(response_body, "citations", [])

            {:ok,
             %{
               answer: "## Perplexity Search-Agent Result\n" <> content,
               citations: citations
             }}
          else
            {:error, "Invalid response from Perplexity API"}
          end

        {:error, {status, response_body}} ->
          error_text = format_error_body(response_body)
          {:error, "Perplexity API error: #{status} #{error_text}"}

        {:error, exception} ->
          Logger.warning("Perplexity request failed: #{Exception.message(exception)}")
          {:error, "Perplexity API error: #{Exception.message(exception)}"}
      end
    end
  end

  defp format_error_body(body) when is_binary(body), do: body

  defp format_error_body(body) do
    case Jason.encode(body) do
      {:ok, encoded} -> encoded
      _ -> inspect(body)
    end
  end
end

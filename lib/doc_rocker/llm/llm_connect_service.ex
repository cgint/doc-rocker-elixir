defmodule DocRocker.LlmConnectService do
  @moduledoc false

  require Logger

  alias DocRocker.HttpClient

  @api_endpoints %{
    "openai" => "https://api.openai.com/v1/chat/completions",
    "anthropic" => "https://api.anthropic.com/v1/messages",
    "gemini" => "https://generativelanguage.googleapis.com/v1beta",
    "mistral" => "https://api.mistral.ai/v1/chat/completions",
    "openrouter" => "https://openrouter.ai/api/v1/chat/completions"
  }

  @temperature 0.3
  @max_output_tokens 8192

  def generate_answer_raw(provider, model, api_key, messages) do
    try do
      case provider do
        "openai" -> call_openai(model, api_key, messages)
        "anthropic" -> call_anthropic(model, api_key, messages)
        "gemini" -> call_gemini(model, api_key, messages)
        "mistral" -> call_mistral(model, api_key, messages)
        "openrouter" -> call_openrouter(model, api_key, messages)
        _ -> raise "Unsupported provider \"#{provider}\""
      end
    rescue
      error ->
        Logger.error("Error in chat endpoint: #{Exception.message(error)}")
        raise "An error occurred while calling the LLM for the final response. #{Exception.message(error)}"
    end
  end

  def generate_answer(provider, model, api_key, messages) do
    generate_answer_raw(provider, model, api_key, messages).answer
  rescue
    error -> Exception.message(error)
  end

  defp call_openai(model, api_key, messages) do
    request_body = %{
      model: model,
      messages: messages,
      temperature: @temperature,
      max_tokens: @max_output_tokens
    }

    headers = [
      {"content-type", "application/json"},
      {"authorization", "Bearer #{api_key}"}
    ]

    case HttpClient.post_json(@api_endpoints["openai"], headers, request_body) do
      {:ok, data} ->
        if Map.has_key?(data, "error") do
          raise "OpenAI API error: #{Jason.encode!(data["error"])}"
        end

        answer = get_in(data, ["choices", Access.at(0), "message", "content"])

        %{
          answer: answer,
          token_info: %{
            total_tokens: get_in(data, ["usage", "total_tokens"]),
            prompt_tokens: get_in(data, ["usage", "prompt_tokens"]),
            completion_tokens: get_in(data, ["usage", "completion_tokens"])
          },
          id: data["id"],
          model: data["model"],
          object: data["object"],
          created: data["created"]
        }

      {:error, {status, _body}} ->
        raise "OpenAI API error: #{Plug.Conn.Status.reason_phrase(status)}"

      {:error, exception} ->
        raise "OpenAI API error: #{Exception.message(exception)}"
    end
  end

  defp call_anthropic(model, api_key, messages) do
    request_body = %{
      model: model,
      system: """
      You are a helpful AI assistant that answers questions in a concise and friendly manner.
      You are given a question and a context.
      You need to answer the question based on the context.
      Answer the question in natural language.
      If you don't know the answer, just say "I don't know".
      """,
      messages:
        Enum.map(messages, fn message ->
          %{
            role: if(message.role == "user", do: "user", else: "assistant"),
            content: message.content
          }
        end),
      max_tokens: @max_output_tokens,
      temperature: @temperature
    }

    headers = [
      {"content-type", "application/json"},
      {"x-api-key", api_key},
      {"anthropic-version", "2023-06-01"}
    ]

    case HttpClient.post_json(@api_endpoints["anthropic"], headers, request_body) do
      {:ok, data} ->
        if Map.has_key?(data, "error") do
          raise "Anthropic API error: #{Jason.encode!(data["error"])}"
        end

        answer = get_in(data, ["content", Access.at(0), "text"])
        usage = Map.get(data, "usage", %{})

        %{
          answer: answer,
          token_info: %{
            total_tokens: (usage["input_tokens"] || 0) + (usage["output_tokens"] || 0),
            input_tokens: usage["input_tokens"],
            output_tokens: usage["output_tokens"],
            cache_creation_input_tokens: usage["cache_creation_input_tokens"],
            cache_read_input_tokens: usage["cache_read_input_tokens"]
          },
          id: data["id"],
          model: data["model"],
          type: data["type"],
          role: data["role"],
          stop_reason: data["stop_reason"]
        }

      {:error, {status, _body}} ->
        raise "Anthropic API error: #{Plug.Conn.Status.reason_phrase(status)}"

      {:error, exception} ->
        raise "Anthropic API error: #{Exception.message(exception)}"
    end
  end

  defp call_gemini(model, api_key, messages) do
    prompt = Enum.map(messages, & &1.content) |> Enum.join("\n")
    endpoint = "#{@api_endpoints["gemini"]}/#{model}:generateContent?key=#{api_key}"

    request_body = %{
      contents: [%{parts: [%{text: prompt}]}],
      generationConfig: %{
        temperature: @temperature,
        maxOutputTokens: @max_output_tokens
      },
      safetySettings: [
        %{category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_NONE"}
      ]
    }

    headers = [{"content-type", "application/json"}]

    case HttpClient.post_json(endpoint, headers, request_body) do
      {:ok, data} ->
        if Map.has_key?(data, "error") do
          raise "Gemini API error: #{Jason.encode!(data["error"])}"
        end

        answer = get_in(data, ["candidates", Access.at(0), "content", "parts", Access.at(0), "text"])
        usage = Map.get(data, "usageMetadata", %{})

        %{
          answer: answer,
          token_info: %{
            total_tokens: usage["totalTokenCount"],
            promptTokenCount: usage["promptTokenCount"],
            candidatesTokenCount: usage["candidatesTokenCount"],
            promptTokensDetails: usage["promptTokensDetails"],
            candidatesTokensDetails: usage["candidatesTokensDetails"]
          },
          model: model
        }

      {:error, {status, body}} ->
        error_text = format_error_body(body)
        raise "Gemini API error: #{Plug.Conn.Status.reason_phrase(status)} (#{status}) - resData: #{error_text}"

      {:error, exception} ->
        raise "Gemini API error: #{Exception.message(exception)}"
    end
  end

  defp call_mistral(model, api_key, messages) do
    request_body = %{
      model: model,
      messages: messages,
      temperature: @temperature,
      max_tokens: @max_output_tokens
    }

    headers = [
      {"content-type", "application/json"},
      {"authorization", "Bearer #{api_key}"}
    ]

    case HttpClient.post_json(@api_endpoints["mistral"], headers, request_body) do
      {:ok, data} ->
        if Map.has_key?(data, "error") do
          raise "Mistral API error: #{Jason.encode!(data["error"])}"
        end

        answer = get_in(data, ["choices", Access.at(0), "message", "content"])

        %{
          answer: answer,
          token_info: %{
            total_tokens: get_in(data, ["usage", "total_tokens"]),
            prompt_tokens: get_in(data, ["usage", "prompt_tokens"]),
            completion_tokens: get_in(data, ["usage", "completion_tokens"])
          },
          id: data["id"],
          model: model,
          object: data["object"],
          created: data["created"]
        }

      {:error, {status, _body}} ->
        raise "Mistral API error: #{Plug.Conn.Status.reason_phrase(status)}"

      {:error, exception} ->
        raise "Mistral API error: #{Exception.message(exception)}"
    end
  end

  defp call_openrouter(model, api_key, messages) do
    request_body = %{
      model: model,
      messages: messages,
      temperature: @temperature,
      max_tokens: @max_output_tokens
    }

    headers = [
      {"content-type", "application/json"},
      {"authorization", "Bearer #{api_key}"}
    ]

    case HttpClient.post_json(@api_endpoints["openrouter"], headers, request_body) do
      {:ok, data} ->
        if Map.has_key?(data, "error") do
          raise "OpenRouter API error: #{Jason.encode!(data["error"])}"
        end

        answer = get_in(data, ["choices", Access.at(0), "message", "content"])

        %{
          answer: answer,
          token_info: %{
            total_tokens: get_in(data, ["usage", "total_tokens"]),
            prompt_tokens: get_in(data, ["usage", "prompt_tokens"]),
            completion_tokens: get_in(data, ["usage", "completion_tokens"])
          },
          id: data["id"],
          model: data["model"],
          provider: data["provider"],
          object: data["object"],
          created: data["created"]
        }

      {:error, {status, _body}} ->
        raise "OpenRouter API error: #{Plug.Conn.Status.reason_phrase(status)}"

      {:error, exception} ->
        raise "OpenRouter API error: #{Exception.message(exception)}"
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

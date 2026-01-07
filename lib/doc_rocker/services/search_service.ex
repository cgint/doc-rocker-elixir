defmodule DocRocker.Services.SearchService do
  @moduledoc false

  require Logger

  alias DocRocker.Config
  alias DocRocker.Llm.Prompts
  alias DocRocker.LlmConnectService
  alias DocRocker.SearchEngines.Perplexity
  alias DocRocker.SearchEngines.Tavily

  @search_timeout_ms 120_000

  def search_documentation(query, picked_domains) do
    if is_nil(query) or String.trim(query) == "" do
      raise "Query is required"
    end

    if is_nil(picked_domains) or picked_domains == [] do
      raise "At least one documentation source must be selected"
    end

    picked_domains_query_string =
      picked_domains
      |> Enum.map(&"site:#{&1}")
      |> Enum.join(" ")

    perplexity_query = String.trim(query <> " " <> picked_domains_query_string)

    perplexity_task = Task.async(fn -> Perplexity.search(perplexity_query, []) end)
    tavily_task = Task.async(fn -> Tavily.search(query, picked_domains) end)

    perplexity_result = await_search(perplexity_task, "Perplexity")
    tavily_result = await_search(tavily_task, "Doc-Rocker")

    combined_answer = tavily_result.answer <> "\n\n" <> perplexity_result.answer

    combined_answer =
      try do
        provider = Config.combiner_provider()
        model = Config.combiner_provider_model()
        api_key = Config.combiner_api_key()

        llm_response =
          LlmConnectService.generate_answer_raw(provider, model, api_key, [
            %{role: "user", content: Prompts.get_combiner_prompt(query, combined_answer)}
          ])

        model_info_string = "_AI-Model: " <> llm_response.model <> "_"

        warning_string =
          "_**Please verify the information before using it.** The answer is based on search results still may contain errors. Check the links below for more information._"

        llm_answer_cleaned = String.trim(llm_response.answer)

        "## AI Answer\n" <>
          llm_answer_cleaned <>
          "\n\n---\n\n" <>
          warning_string <>
          "\n\n" <>
          model_info_string
      rescue
        error ->
          Logger.error("Failed to get combined answer: #{Exception.message(error)}")

          "Error retrieving combined answer. Here is the raw answer from the search engines: " <>
            combined_answer
      end

    combined_result = %{
      answer: combined_answer,
      citations: (tavily_result.citations || []) ++ (perplexity_result.citations || [])
    }

    %{
      combined_search_result: combined_result,
      raw_search_results: [tavily_result, perplexity_result]
    }
  end

  defp await_search(task, label) do
    result =
      case Task.yield(task, @search_timeout_ms) || Task.shutdown(task, :brutal_kill) do
        {:ok, {:ok, value}} -> {:ok, value}
        {:ok, {:error, error}} -> {:error, error}
        {:ok, value} -> {:ok, value}
        nil -> {:error, "Search timed out"}
      end

    case result do
      {:ok, value} ->
        value

      {:error, error} ->
        Logger.error("#{label} search error: #{format_error(error)}")

        %{
          answer: "**#{label} Search Error:** #{format_error(error)}",
          citations: []
        }
    end
  end

  defp format_error(error) when is_binary(error), do: error
  defp format_error(%{message: message}) when is_binary(message), do: message
  defp format_error(error) when is_exception(error), do: Exception.message(error)
  defp format_error(error), do: inspect(error)
end

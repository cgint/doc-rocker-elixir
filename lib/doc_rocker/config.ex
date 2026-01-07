defmodule DocRocker.Config do
  @moduledoc false

  def perplexity_api_key, do: System.get_env("VITE_PERPLEXITY_API_KEY")
  def perplexity_model, do: System.get_env("VITE_PERPLEXITY_MODEL")
  def tavily_api_key, do: System.get_env("VITE_TAVILY_API_KEY")
  def combiner_provider, do: System.get_env("VITE_COMBINER_PROVIDER")
  def combiner_provider_model, do: System.get_env("VITE_COMBINER_PROVIDER_MODEL")
  def combiner_api_key, do: System.get_env("VITE_COMBINER_API_KEY")
end

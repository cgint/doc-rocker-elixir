defmodule DocRockerWeb.HomeLive do
  use DocRockerWeb, :live_view

  @max_characters 400
  @near_limit_threshold 0.8

  @documentation_picks [
    %{name: "EU Alternatives", domain: "european-alternatives.eu", selected: false},
    %{name: "Drugs.com Effects", domain: "drugs.com", selected: false},
    %{name: "Worldwide Search", domain: "*", selected: false},
    %{name: "Langchain-JS", domain: "js.langchain.com", selected: false},
    %{name: "Langchain-Python", domain: "python.langchain.com", selected: false},
    %{name: "LlamaIndex", domain: "docs.llamaindex.ai", selected: false},
    %{name: "Google Shopping API", domain: "developers.google.com", selected: false},
    %{name: "Google Ads API", domain: "developers.google.com", selected: false},
    %{name: "Intercom", domain: "intercom.com", selected: false}
  ]

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       query: "",
       loading: false,
       error: nil,
       response: "",
       citations: [],
       raw_results: [],
       status_message: "",
       query_too_long: false,
       query_near_limit: false,
       character_count: 0,
       picks: @documentation_picks,
       custom_domain: "",
       custom_domain_error: "",
       show_custom_input: false
     )}
  end

  def handle_event("validate", %{"chat" => %{"query" => query}}, socket) do
    {count, too_long, near_limit} = query_metrics(query)

    {:noreply,
     assign(socket,
       query: query,
       character_count: count,
       query_too_long: too_long,
       query_near_limit: near_limit
     )}
  end

  def handle_event("submit", _params, socket) do
    query = socket.assigns.query
    selected = selected_picks(socket.assigns.picks)

    error =
      cond do
        String.trim(query) == "" ->
          "Please enter a query"

        String.length(query) > @max_characters ->
          "Query is too long. Tavily search requires 400 characters or less."

        selected == [] ->
          "Please select at least one documentation source"

        not has_worldwide?(selected) and length(selected) > 1 ->
          "Currently limited to 1 documentation source while in beta. This limit will be increased over time."

        true ->
          nil
      end

    if error do
      {:noreply, assign(socket, error: error)}
    else
      {:noreply,
       assign(socket,
         error: nil,
         response: "",
         citations: [],
         raw_results: [],
         status_message: "",
         loading: false
       )}
    end
  end

  def handle_event("toggle_pick", %{"index" => index}, socket) do
    index = String.to_integer(index)

    picks =
      socket.assigns.picks
      |> Enum.with_index()
      |> Enum.map(fn {pick, i} ->
        cond do
          i == index and pick.selected -> pick
          i == index -> %{pick | selected: true}
          true -> %{pick | selected: false}
        end
      end)

    {:noreply, assign(socket, picks: picks)}
  end

  def handle_event("toggle_custom_input", _params, socket) do
    show_custom_input = not socket.assigns.show_custom_input
    custom_domain_error = if show_custom_input, do: socket.assigns.custom_domain_error, else: ""

    {:noreply,
     assign(socket,
       show_custom_input: show_custom_input,
       custom_domain_error: custom_domain_error
     )}
  end

  def handle_event("custom_domain_change", %{"custom_domain" => custom_domain}, socket) do
    {:noreply, assign(socket, custom_domain: custom_domain)}
  end

  def handle_event("add_custom_domain", %{"custom_domain" => custom_domain}, socket) do
    domain = String.trim(custom_domain || "")

    cond do
      domain == "" ->
        {:noreply, assign(socket, custom_domain_error: "Please enter a domain")}

      not valid_domain?(domain) ->
        {:noreply,
         assign(socket,
           custom_domain_error: "Please enter a valid domain (e.g., example.com)"
         )}

      true ->
        picks =
          socket.assigns.picks
          |> Enum.reject(fn pick -> String.starts_with?(pick.name, "Custom: ") end)
          |> Enum.map(fn pick -> %{pick | selected: false} end)

        custom_pick = %{name: "Custom: #{domain}", domain: domain, selected: true}

        {:noreply,
         assign(socket,
           picks: picks ++ [custom_pick],
           custom_domain_error: "",
           show_custom_input: false,
           custom_domain: domain
         )}
    end
  end

  defp query_metrics(query) do
    count = String.length(query || "")
    too_long = count > @max_characters
    near_limit = count > @max_characters * @near_limit_threshold
    {count, too_long, near_limit}
  end

  defp selected_picks(picks) do
    Enum.filter(picks, & &1.selected)
  end

  defp has_worldwide?(selected) do
    Enum.any?(selected, &(&1.domain == "*"))
  end

  defp valid_domain?(domain) do
    Regex.match?(~r/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}$/i, domain)
  end

  defp markdown_display(assigns) do
    ~H"""
    <div class="markdown-container">
      <div class="markdown-content-wrapper">
        <%= if @show_copy_buttons do %>
          <div class="action-buttons">
            <button class="action-button" type="button" title="Copy Markdown" aria-label="Copy Markdown">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
              </svg>
            </button>
            <button class="action-button" type="button" title="Copy Rich Text" aria-label="Copy Rich Text">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                <polyline points="16 17 21 12 16 7"></polyline>
                <line x1="21" y1="12" x2="9" y2="12"></line>
              </svg>
            </button>
          </div>
        <% end %>

        <div class="markdown-content"><%= @markdown %></div>
      </div>
    </div>
    """
  end
end

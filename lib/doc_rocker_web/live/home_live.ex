defmodule DocRockerWeb.HomeLive do
  use DocRockerWeb, :live_view

  alias DocRocker.Services.SearchService

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
       show_custom_input: false,
       picks_initialized: false
     )}
  end

  def handle_event("validate", params, socket) do
    query =
      get_in(params, ["chat", "query"]) ||
        params["query"] ||
        socket.assigns.query ||
        ""

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
    if socket.assigns.loading do
      {:noreply, socket}
    else
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
        picked_domains = Enum.map(selected, & &1.domain)
        parent = self()

        Task.start(fn -> run_search(parent, query, picked_domains) end)

        socket =
          socket
          |> assign(
            error: nil,
            response: "",
            citations: [],
            raw_results: [],
            status_message: "",
            loading: true
          )

        Process.send_after(self(), {:scroll_to, "status_message", "nearest"}, 10)

        {:noreply, socket}
      end
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

    socket =
      socket
      |> assign(picks: picks)
      |> push_event("save_picks", %{names: selected_pick_names(picks)})

    {:noreply, socket}
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

        picks = picks ++ [custom_pick]

        socket =
          socket
          |> assign(
            picks: picks,
            custom_domain_error: "",
            show_custom_input: false,
            custom_domain: domain
          )
          |> push_event("save_picks", %{names: selected_pick_names(picks)})

        {:noreply, socket}
    end
  end

  def handle_event("select_pick_by_name", %{"name" => name}, socket) do
    picks =
      socket.assigns.picks
      |> Enum.map(fn pick ->
        if pick.name == name do
          %{pick | selected: true}
        else
          %{pick | selected: false}
        end
      end)

    {:noreply, assign(socket, picks: picks, picks_initialized: true)}
  end

  def handle_event("set_custom_domain", %{"domain" => domain}, socket) do
    domain = String.trim(domain || "")

    if domain == "" or not valid_domain?(domain) do
      {:noreply, assign(socket, picks_initialized: true)}
    else
      picks =
        socket.assigns.picks
        |> Enum.reject(fn pick -> String.starts_with?(pick.name, "Custom: ") end)
        |> Enum.map(fn pick -> %{pick | selected: false} end)

      custom_pick = %{name: "Custom: #{domain}", domain: domain, selected: true}
      picks = picks ++ [custom_pick]

      {:noreply,
       assign(socket,
         picks: picks,
         custom_domain: domain,
         custom_domain_error: "",
         show_custom_input: false,
         picks_initialized: true
       )}
    end
  end

  def handle_info({:search_status, message}, socket) do
    status_message =
      if socket.assigns.status_message == "" do
        message
      else
        socket.assigns.status_message <> "<br>" <> message
      end

    {:noreply, assign(socket, status_message: status_message)}
  end

  def handle_info({:search_result, result}, socket) do
    combined = result.combined_search_result

    socket =
      assign(socket,
        response: combined.answer,
        citations: combined.citations || [],
        raw_results: result.raw_search_results || [],
        loading: false,
        status_message: ""
      )

    Process.send_after(self(), {:scroll_to, "combined_result", "start"}, 10)

    {:noreply, socket}
  end

  def handle_info({:search_error, error_message}, socket) do
    {:noreply,
     assign(socket,
       error: error_message,
       loading: false,
       status_message: ""
     )}
  end

  def handle_info({:scroll_to, id, block}, socket) do
    {:noreply, push_event(socket, "scroll_to", %{id: id, block: block})}
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

  defp selected_pick_names(picks) do
    Enum.reduce(picks, [], fn pick, acc ->
      if pick.selected do
        name =
          if String.starts_with?(pick.name, "Custom: ") do
            "custom:" <> pick.domain
          else
            pick.name
          end

        acc ++ [name]
      else
        acc
      end
    end)
  end

  defp has_worldwide?(selected) do
    Enum.any?(selected, &(&1.domain == "*"))
  end

  defp valid_domain?(domain) do
    Regex.match?(~r/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}$/i, domain)
  end

  defp run_search(parent, query, picked_domains) do
    send(parent, {:search_status, "Starting search engines..."})

    try do
      result = SearchService.search_documentation(query, picked_domains)
      send(parent, {:search_status, "Search completed. Preparing results..."})
      send(parent, {:search_result, result})
    rescue
      error ->
        send(parent, {:search_error, Exception.message(error)})
    end
  end
end

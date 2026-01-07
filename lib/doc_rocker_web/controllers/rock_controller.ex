defmodule DocRockerWeb.RockController do
  use DocRockerWeb, :controller

  require Logger

  alias DocRocker.Services.SearchService

  @required_user_agent "Web-Search-Doc-Rocker-MCP/0.1.0"

  def create(conn, params) do
    user_agent = get_req_header(conn, "user-agent") |> List.first() || ""
    content_type = get_req_header(conn, "content-type") |> List.first() || ""

    Logger.info("Rock API POST request received:")
    Logger.info("  Method: #{conn.method}")
    Logger.info("  Content-Type: #{content_type}")
    Logger.info("  User-Agent: #{user_agent}")

    if user_agent != @required_user_agent do
      Logger.info("Unauthorized User-Agent: #{user_agent}")
      Logger.info("Expected User-Agent: #{@required_user_agent}")

      conn
      |> put_status(:unauthorized)
      |> json(%{
        error: "Unauthorized: Invalid User-Agent header",
        expected: @required_user_agent,
        received: user_agent
      })
    else
      Logger.info("User-Agent validation passed")

      query = params["query"]
      domain_restriction = params["domainRestriction"]

      if not is_binary(query) do
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Query parameter is required and must be a string"})
      else
        if not is_binary(domain_restriction) do
          conn
          |> put_status(:bad_request)
          |> json(%{error: "Domain restriction parameter is required and must be a string"})
        else
          picked_domains = if domain_restriction == "*", do: ["*"], else: [domain_restriction]

          Logger.info("Starting search with domains: #{inspect(picked_domains)}")

          try do
            search_result = SearchService.search_documentation(query, picked_domains)

            Logger.info("Rock API search completed successfully")

            json(conn, %{
              message: "Rock API - Search completed successfully",
              timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
              request: %{
                query: query,
                domainRestriction: domain_restriction,
                pickedDomains: picked_domains
              },
              result: search_result
            })
          rescue
            error ->
              Logger.error("Rock API Error: #{Exception.message(error)}")

              conn
              |> put_status(:internal_server_error)
              |> json(%{error: "Search error: #{Exception.message(error)}"})
          end
        end
      end
    end
  rescue
    %Jason.DecodeError{} ->
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Invalid JSON in request body"})

    error ->
      Logger.error("Rock API Error: #{Exception.message(error)}")

      conn
      |> put_status(:internal_server_error)
      |> json(%{error: "Internal server error"})
  end
end

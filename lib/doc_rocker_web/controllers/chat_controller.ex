defmodule DocRockerWeb.ChatController do
  use DocRockerWeb, :controller

  require Logger

  alias DocRocker.Services.SearchService

  def create(conn, params) do
    query = params["query"]
    documentation_picks = params["documentationPicks"]

    cond do
      not is_binary(query) or String.trim(query) == "" ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Query is required"})

      not is_list(documentation_picks) or documentation_picks == [] ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "At least one documentation source must be selected"})

      true ->
        picked_domains =
          documentation_picks
          |> Enum.map(&Map.get(&1, "domain"))
          |> Enum.filter(&is_binary/1)

        conn =
          conn
          |> put_resp_content_type("text/event-stream")
          |> put_resp_header("cache-control", "no-cache")
          |> put_resp_header("connection", "keep-alive")
          |> send_chunked(200)

        try do
          conn = send_stream_message(conn, "status", %{message: "Starting search engines..."})
          result = SearchService.search_documentation(query, picked_domains)
          conn = send_stream_message(conn, "status", %{message: "Search completed. Preparing results..."})
          send_stream_message(conn, "final", %{result: result})
        rescue
          error ->
            Logger.error("Error in chat endpoint: #{Exception.message(error)}")

            send_stream_message(conn, "status", %{
              message:
                "An error occurred while processing your request: " <>
                  Exception.message(error)
            })
        end
    end
  rescue
    error ->
      Logger.error("Error in chat endpoint: #{Exception.message(error)}")

      conn
      |> put_status(:internal_server_error)
      |> json(%{error: Exception.message(error)})
  end

  defp send_stream_message(conn, type, data) do
    message = "data: " <> Jason.encode!(Map.put(data, :type, type)) <> "\n\n"

    case chunk(conn, message) do
      {:ok, conn} -> conn
      {:error, reason} ->
        Logger.warning("Error writing to stream: #{inspect(reason)}")
        conn
    end
  end
end

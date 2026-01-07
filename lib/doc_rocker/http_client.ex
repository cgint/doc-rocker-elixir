defmodule DocRocker.HttpClient do
  @moduledoc false

  def post_json(url, headers, body) do
    case Req.post(url, json: body, headers: headers) do
      {:ok, %{status: status, body: response_body}} when status in 200..299 ->
        {:ok, response_body}

      {:ok, %{status: status, body: response_body}} ->
        {:error, {status, response_body}}

      {:error, exception} ->
        {:error, exception}
    end
  end
end

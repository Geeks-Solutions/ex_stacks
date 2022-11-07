defmodule ExStacks.HttpClient do
  @moduledoc """
  HTTP Client for the library that handles relaying HTTP requests.
  """
  @moduledoc false

  @doc """
    Sends a GET request.

  ## Examples

      iex> endpoint_get_callback("https://some_endpoint")
      %{message: "some response"}

  ## Returns

      Returns either the body of a successful request or an ``{:error, error}`` tuple.
  """
  def endpoint_get_callback(
        url,
        headers \\ [{"content-type", "application/json"}]
      ) do
    case HTTPoison.get(url, headers) do
      {:ok, response} ->
        fetch_response_body(response)

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
    Sends a PUT request.

  ## Examples

      iex> endpoint_put_callback("https://some_endpoint", %{arg_1: "value_1})
      %{message: "some response"}

  ## Returns

      Returns either the body of a successful request or an ``{:error, error}`` tuple.
  """
  def endpoint_put_callback(
        url,
        args,
        headers \\ [{"content-type", "application/json"}]
      ) do
    {:ok, body} = args |> Poison.encode()

    case HTTPoison.put(url, body, headers) do
      {:ok, response} ->
        fetch_response_body(response)

      {:error, _error} ->
        {:error, "users credentials server error"}
    end
  end

  @doc """
    Sends a POST request.

  ## Examples

      iex> endpoint_post_callback("https://some_endpoint", %{arg_1: "value_1})
      %{message: "some response"}

  ## Returns

      Returns either the body of a successful request or an ``{:error, error}`` tuple.
  """
  def endpoint_post_callback(
        url,
        args,
        headers \\ [{"content-type", "application/json"}]
      ) do
    {:ok, body} = args |> Poison.encode()

    case HTTPoison.post(url, body, headers) do
      {:ok, response} ->
        fetch_response_body(response)

      {:error, error} ->
        {:error, error}
    end
  end

  defp fetch_response_body(response) do
    case Poison.decode(response.body) do
      {:ok, body} ->
        body

      _ ->
        {:error, response.body}
    end
  end
end

defmodule ExStacks.Helpers do
  @moduledoc """
  Helper functions for the library
  """
  def env(key, opts \\ %{default: nil, raise: false}) do
    Application.get_env(:ex_stacks, key)
    |> case do
      nil ->
        if opts |> Map.get(:raise, false),
          do: raise("Please configure :#{key} to use ex_stacks as desired,
          i.e:
          config, :ex_stacks,
            #{key}: VALUE_HERE"),
          else: opts |> Map.get(:default)

      value ->
        value
    end
  end

  def node_url do
    env(:node_url, %{raise: true})
  end

  @doc """
  Convert map string keys to :atom keys
  """
  def atomize_keys(nil), do: nil

  # Structs don't do enumerable and anyway the keys are already
  # atoms
  def atomize_keys(%{__struct__: _} = struct) do
    struct
  end

  def atomize_keys(%{} = map) do
    map
    |> Enum.map(fn {k, v} -> {atomize(k), atomize_keys(v)} end)
    |> Enum.into(%{})
  end

  # Walk the list and atomize the keys of
  # of any map members
  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  def atomize_keys(not_a_map) do
    not_a_map
  end

  def atomize(k) when is_binary(k) do
    String.to_atom(k)
  end

  def atomize(k) do
    k
  end

  def format_query_params(map) do
    Enum.map(map, fn
      {k, v} when is_atom(k) -> "#{Atom.to_string(k)}=#{v}"
      {k, v} -> "#{k}=#{v}"
    end)
    |> Enum.join("&")
  end
end
defmodule ExStacks.StacksAPI do
  @moduledoc """
  This module is responsible of communicating with the Stacks Blockchain
  """
  alias ExStacks.{Helpers, HttpClient}

  defp required_params_available?(params, keywords) when is_map(params) do
    params = params |> Helpers.atomize_keys()

    {Enum.all?(keywords, fn required_param ->
       not is_nil(Map.get(params, required_param))
     end), params}
  end

  defp required_params_available?(_params, _keywords), do: false

  defp add_optional_param(body, params, key) do
    value = Map.get(params, key)

    if is_nil(value) do
      body
    else
      Map.merge(body, %{Atom.to_string(key) => value})
    end
  end

  def request(string, params \\ %{})

  def request("account_balance", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, [:principal]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/balances?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_stx_balance", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, [:principal]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/stx?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_transactions", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, [:principal]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/transactions?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_transactions_with_transfers", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, [:principal]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/transactions_with_transfers?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_transaction_by_id", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal, :tx_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        tx_id = Map.get(params, :tx_id)
        query_params = Map.drop(params, [:principal, :tx_id]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/#{tx_id}/with_transfers?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_nonces", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, [:principal]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/nonces?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_stx_inbound", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, [:principal]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/stx_inbound?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_information", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, [:principal]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/#{principal}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("recent_blocks", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("block_by_hash", params) do
    node_base_url = Helpers.node_url()
    required_params = [:hash]

    case required_params_available?(params, required_params) do
      {true, params} ->
        hash = Map.get(params, :hash)
        query_params = Map.drop(params, [:hash]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block/#{hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("block_by_height", params) do
    node_base_url = Helpers.node_url()
    required_params = [:height]

    case required_params_available?(params, required_params) do
      {true, params} ->
        hash = Map.get(params, :height)
        query_params = Map.drop(params, [:height]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block/by_height/#{hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("block_by_burnchain_height", params) do
    node_base_url = Helpers.node_url()
    required_params = [:burn_block_height]

    case required_params_available?(params, required_params) do
      {true, params} ->
        hash = Map.get(params, :burn_block_height)
        query_params = Map.drop(params, [:burn_block_height]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block/by_burn_block_height/#{hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("block_by_burnchain_hash", params) do
    node_base_url = Helpers.node_url()
    required_params = [:burn_block_hash]

    case required_params_available?(params, required_params) do
      {true, params} ->
        hash = Map.get(params, :burn_block_hash)
        query_params = Map.drop(params, [:burn_block_hash]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block/by_burn_block_hash/#{hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("estimated_stx_transfer_transaction_fee", _params) do
    node_base_url = Helpers.node_url()

    url =
      node_base_url <>
        "/v2/fees/transfer"

    HttpClient.endpoint_get_callback(url)
  end

  def request("estimated_transaction_fee", params) do
    node_base_url = Helpers.node_url()
    required_params = [:transaction_payload]

    case required_params_available?(params, required_params) do
      {true, params} ->
        transaction_payload = Map.get(params, :transaction_payload)

        body =
          %{"transaction_payload" => transaction_payload}
          |> add_optional_param(params, :estimated_len)

        url =
          node_base_url <>
            "/v2/fees/transaction"

        HttpClient.endpoint_post_callback(url, body)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("fts_metadata", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tokens/ft/metadata?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("ft_by_contract_id_metadata", params) do
    node_base_url = Helpers.node_url()
    required_params = [:contract_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        contract_id = Map.get(params, :contract_id)

        url =
          node_base_url <>
            "/extended/v1/tokens/#{contract_id}/ft/metadata"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("core_api_info", _params) do
    HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v2/info")
  end

  def request("api_status", _params) do
    HttpClient.endpoint_get_callback(Helpers.node_url() <> "/extended/v1/status")
  end

  def request("network_block_time", _params) do
    HttpClient.endpoint_get_callback(
      Helpers.node_url() <> "/extended/v1/info/network_block_times"
    )
  end

  def request("proof_of_transfer_details", _params) do
    HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v2/pox")
  end

  def request("given_network_block_time", params) do
    url = Helpers.node_url()
    required_params = [:network]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network = Map.get(params, :network)

        HttpClient.endpoint_get_callback(url <> "/extended/v1/info/network_block_time/#{network}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("stx_supply", params) do
    node_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()
        HttpClient.endpoint_get_callback(node_url <> "/extended/v1/stx_supply?#{query_params}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("legacy_stx_supply", params) do
    node_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        HttpClient.endpoint_get_callback(
          node_url <> "/extended/v1/stx_supply/legacy_format?#{query_params}"
        )

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("total_stx_supply_plain_text", _params) do
    HttpClient.endpoint_get_callback(Helpers.node_url() <> "/extended/v1/stx_supply/total/plain")
  end

  def request("circulating_stx_supply_plain_text", _params) do
    HttpClient.endpoint_get_callback(
      Helpers.node_url() <> "/extended/v1/stx_supply/circulating/plain"
    )
  end

  def request("recent_microblocks", params) do
    url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        HttpClient.endpoint_get_callback(url <> "/extended/v1/microblock?#{query_params}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("microblock", params) do
    url = Helpers.node_url()
    required_params = [:hash]

    case required_params_available?(params, required_params) do
      {true, params} ->
        hash = Map.get(params, :hash)

        HttpClient.endpoint_get_callback(url <> "/extended/v1/microblock/#{hash}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("transactions_in_unanchored_microblocks", _params) do
    HttpClient.endpoint_get_callback(
      Helpers.node_url() <> "/extended/v1/microblock/unanchored/txs"
    )
  end

  def request("namespace_price", params) do
    url = Helpers.node_url()
    required_params = [:t_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        t_id = Map.get(params, :t_id)

        HttpClient.endpoint_get_callback(url <> "/v2/prices/namespaces/##{t_id}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("name_price", params) do
    url = Helpers.node_url()
    required_params = [:name]

    case required_params_available?(params, required_params) do
      {true, params} ->
        name = Map.get(params, :name)

        HttpClient.endpoint_get_callback(url <> "/v2/prices/names/##{name}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("namespaces", _params) do
    HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v1/namespaces")
  end

  def request("namespace_names", params) do
    url = Helpers.node_url()
    required_params = [:t_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        t_id = Map.get(params, :t_id)
        query_params = params |> Helpers.format_query_params()

        HttpClient.endpoint_get_callback(url <> "/v1/namespaces/##{t_id}/names?#{query_params}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("names", _params) do
    HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v1/names")
  end

  def request("name_details", params) do
    url = Helpers.node_url()
    required_params = [:name]

    case required_params_available?(params, required_params) do
      {true, params} ->
        name = Map.get(params, :name)

        HttpClient.endpoint_get_callback(url <> "/v1/names/#{name}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("name_subdomains", params) do
    url = Helpers.node_url()
    required_params = [:name]

    case required_params_available?(params, required_params) do
      {true, params} ->
        name = Map.get(params, :name)

        HttpClient.endpoint_get_callback(url <> "/v1/names/#{name}/subdomains")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("name_zonefile", params) do
    url = Helpers.node_url()
    required_params = [:name]

    case required_params_available?(params, required_params) do
      {true, params} ->
        name = Map.get(params, :name)

        HttpClient.endpoint_get_callback(url <> "/v1/names/#{name}/zonefile")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("name_historical_zonefile", params) do
    url = Helpers.node_url()
    required_params = [:name, :zonefile_hash]

    case required_params_available?(params, required_params) do
      {true, params} ->
        name = Map.get(params, :name)
        zonefile_hash = Map.get(params, :zonefile_hash)
        HttpClient.endpoint_get_callback(url <> "/v1/names/#{name}/zonefile/#{zonefile_hash}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("names_owned_by_address", params) do
    url = Helpers.node_url()
    required_params = [:blockchain, :address]

    case required_params_available?(params, required_params) do
      {true, params} ->
        blockchain = Map.get(params, :blockchain)
        address = Map.get(params, :address)
        HttpClient.endpoint_get_callback(url <> "/v1/addresses/#{blockchain}/#{address}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("nft_holdings", params) do
    url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        HttpClient.endpoint_get_callback(
          url <> "/extended/v1/tokens/nft/holdings?#{query_params}"
        )

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("nft_history", params) do
    url = Helpers.node_url()
    required_params = [:asset_identifier, :value]

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        HttpClient.endpoint_get_callback(url <> "/extended/v1/tokens/nft/history?#{query_params}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("nft_mints", params) do
    url = Helpers.node_url()
    required_params = [:asset_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        HttpClient.endpoint_get_callback(url <> "/extended/v1/tokens/nft/mints?#{query_params}")

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("nfts_metadata", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tokens/nft/metadata?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("nft_by_contract_id_metadata", params) do
    node_base_url = Helpers.node_url()
    required_params = [:contract_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        contract_id = Map.get(params, :contract_id)

        url =
          node_base_url <>
            "/extended/v1/tokens/#{contract_id}/nft/metadata"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("contract_info", params) do
    node_base_url = Helpers.node_url()
    required_params = [:contract_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        contract_id = Map.get(params, :contract_id)
        query_params = Map.drop(params, [:contract_id]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/contract/#{contract_id}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("contracts_by_trait", params) do
    node_base_url = Helpers.node_url()
    required_params = [:trait_abi]

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/contract/by_trait?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("contract_events", params) do
    node_base_url = Helpers.node_url()
    required_params = [:contract_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        contract_id = Map.get(params, :contract_id)
        query_params = Map.drop(params, [:contract_id]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/contract/#{contract_id}/events?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("contract_interface", params) do
    node_base_url = Helpers.node_url()
    required_params = [:contract_address, :contract_name]

    case required_params_available?(params, required_params) do
      {true, params} ->
        contract_address = Map.get(params, :contract_address)
        contract_name = Map.get(params, :contract_name)

        query_params =
          Map.drop(params, [:contract_name, :contract_address]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/contracts/interface/#{contract_address}/#{contract_name}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("specific_data_map_in_contract", params) do
    node_base_url = Helpers.node_url()
    required_params = [:contract_address, :contract_name, :map_name]

    case required_params_available?(params, required_params) do
      {true, params} ->
        contract_address = Map.get(params, :contract_address)
        contract_name = Map.get(params, :contract_name)
        map_name = Map.get(params, :map_name)

        query_params =
          Map.drop(params, [:contract_name, :contract_address, :map_name])
          |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/map_entry/#{contract_address}/#{contract_name}/#{map_name}?#{query_params}"

        HttpClient.endpoint_post_callback(url, %{})

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("contract_source", params) do
    node_base_url = Helpers.node_url()
    required_params = [:contract_address, :contract_name]

    case required_params_available?(params, required_params) do
      {true, params} ->
        contract_address = Map.get(params, :contract_address)
        contract_name = Map.get(params, :contract_name)

        query_params =
          Map.drop(params, [:contract_name, :contract_address]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/contracts/source/#{contract_address}/#{contract_name}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("read_only_function", params) do
    node_base_url = Helpers.node_url()
    required_params = [:contract_address, :contract_name, :function_name]

    case required_params_available?(params, required_params) do
      {true, params} ->
        contract_address = Map.get(params, :contract_address)
        contract_name = Map.get(params, :contract_name)
        function_name = Map.get(params, :function_name)

        query_params =
          Map.drop(params, [:contract_name, :contract_address, :function_name])
          |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/contracts/call-read/#{contract_address}/#{contract_name}/#{function_name}?#{query_params}"

        HttpClient.endpoint_post_callback(url, %{})

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("recent_transactions", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("mempool_transactions", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx/mempool?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("dropped_mempool_transactions", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx/mempool/dropped?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("details_for_transactions", params) do
    node_base_url = Helpers.node_url()
    required_params = [:tx_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx/multiple?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("transaction", params) do
    node_base_url = Helpers.node_url()
    required_params = [:tx_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        tx_id = Map.get(params, :tx_id)

        url =
          node_base_url <>
            "/extended/v1/tx/#{tx_id}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("raw_transaction", params) do
    node_base_url = Helpers.node_url()
    required_params = [:tx_id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        tx_id = Map.get(params, :tx_id)

        url =
          node_base_url <>
            "/extended/v1/tx/#{tx_id}/raw"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("transactions_by_block_hash", params) do
    node_base_url = Helpers.node_url()
    required_params = [:block_hash]

    case required_params_available?(params, required_params) do
      {true, params} ->
        block_hash = Map.get(params, :block_hash)
        query_params = Map.drop(params, [:block_hash]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx/block/#{block_hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("transactions_by_block_height", params) do
    node_base_url = Helpers.node_url()
    required_params = [:block_height]

    case required_params_available?(params, required_params) do
      {true, params} ->
        block_height = Map.get(params, :block_height)
        query_params = Map.drop(params, [:block_height]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx/block_height/#{block_height}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("transactions_by_address", params) do
    node_base_url = Helpers.node_url()
    required_params = [:address]

    case required_params_available?(params, required_params) do
      {true, params} ->
        address = Map.get(params, :address)
        query_params = Map.drop(params, [:address]) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{address}/mempool?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("transaction_events", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx/events?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, _params} ->
        {:error, :missing_required_params}

      false ->
        {:error, :invalid_params}
    end
  end

  # def request("available_networks", _params) do
  #   HttpClient.endpoint_post_callback(Helpers.node_url() <> "/rosetta/v1/network/list", %{})
  # end
end

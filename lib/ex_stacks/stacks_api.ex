defmodule ExStacks.StacksAPI do
  @moduledoc """
  This module is responsible of communicating with the Stacks Blockchain
  """
  alias ExStacks.{Helpers, HttpClient}

  defp required_params_available?(params, required_params) when is_map(params) do
    params = params |> Helpers.atomize_keys()

    if Enum.all?(required_params, fn required_param ->
         not is_nil(Map.get(params, required_param))
       end) do
      {true, params}
    else
      {false, required_params -- Map.keys(params)}
    end
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

  @doc """
    Used to hit the Stacks API.

  ## Available API Calls (case sensitive)
      - ``available_balances`` - Get Account Balances
      - ``account_stx_balance`` - Get Account STX Balance
      - ``account_transactions`` - Get Account Transactions
      - ``account_transactions_with_transfers`` - Get Account Transactions including STX Transfers for each transaction
      - ``account_transaction_by_id`` - Get Account Transaction information for a specific transaction
      - ``account_nonces`` - Get the latest nonce used by an account
      - ``account_stx_inbound`` - Get the account's inbound STX Transfers
      - ``account_information`` - Get the account's information
      - ``recent_blocks`` - Get the list of recently mined blocks
      - ``block_by_hash`` - Get a block by its hash
      - ``block_by_height`` - Get a block by its height
      - ``block_by_burnchain_hash`` - Get a block by the given burnchain block hash
      - ``block_by_burnchain_height`` - Get a block by the given burnchain block height
      - ``estimated_stx_transfer_transaction_fee`` - Get the estimated fee rate for STX Transfers
      - ``estimated_transaction_fee`` - Get the approximate fee for the supplied transaction.
      - ``fts_metadata`` - Get a list of fungible tokens with their metadata
      - ``ft_by_contract_id_metadata`` - Get the metadata for fungible tokens for a given contract ID.
      - ``core_api_info`` - Get the Core API information
      - ``api_status`` - Get the API Status
      - ``network_block_time`` - Get a network target block time
      - ``proof_of_transfer_details`` - Get PoX information.
      - ``given_network_block_time`` - Get the given network target block time.
      - ``stx_supply`` - Get the total and unlocked STX Supply
      - ``legacy_stx_supply`` - Get the total and unlocked STX Supply with the results formatted for the legacy 1.0 API
      - ``total_stx_supply_plain_text`` - Get the total STX supply as plain text
      - ``circulating_stx_supply_plain_text`` - Get the circulating STX supply as plain text.
      - ``recent_microblocks`` - Get the recent microblocks details.
      - ``microblock`` - Get a microblock by its hash.
      - ``transactions_in_unanchored_microblocks`` - Get the list of transactions that belong to an unanchored microblock.
      - ``namespace_price`` - Get the price of a specific namespace
      - ``name_price`` - Get the price of a specific name
      - ``namespaces`` - Get all namespaces
      - ``namespace_names`` - Get all names that belong to a specific namespace
      - ``names`` - Get all the names that are known to the target node.
      - ``name_details`` - Get the details of a specific name.
      - ``name_subdomains`` - Get the subdomains of a name.
      - ``name_zonefile`` - Get the zonefile of a name.
      - ``name_historical_zonefile`` - Get the historical zonefile of a name.
      - ``names_owned_by_address`` - Get all the names owned by a specific address.
      - ``nfts_metadata`` - Get a list of NFTs with their metadata
      - ``nft_holdings`` - Get all the NFT owned by a given address.
      - ``nft_history`` - Get all the relevant events for a given NFT.
      - ``nft_mints`` - Get all the mint events for a specific NFT asset class.
      - ``nft_by_contract_id_metadata`` - Get the metadata for NFTs belonging to a contract ID.
      - ``contract_info`` - Get a contract's information
      - ``contracts_by_trait`` - Get the list of contracts based on specific traits.
      - ``contract_events`` - Get the events triggered by a contract.
      - ``contract_interface`` - Get a contract's interface
      - ``specific_data_map_in_contract`` - Get a contract's data from a specific data map.
      - ``contract_source`` - Get the contract's Clarity source code.
      - ``read_only_function`` - Call a read-only public function in a specific smart contract.
      - ``recent_transactions`` - Get the list of recently mined transactions.
      - ``mempool_transactions`` - Get all recently broadcasted transactions to the mempool.
      - ``dropped_mempool_transactions`` - Get all recently broadcasted transactions to the mempool that have been dropped.
      - ``details_for_transactions`` - Get a list of transactions using an array of the transaction IDs.
      - ``transaction`` - Get a transaction by its ID.
      - ``raw_transaction`` - Get a raw transaction by its ID. (hex encoded)
      - ``transactions_by_block_hash`` - Get all transactions in a mined block by the block hash.
      - ``transactions_by_block_height`` - Get all transactions in a mined block by the block height.
      - ``transactions_by_address`` - Get all the transactions for a given address that are currently in the mempool.
      - ``transaction_events`` - Get a list of transaction events.
      - ``sign_transaction`` - Returns the signed transaction version of an unsigned transaction payload.
      - ``submit_signed_transaction`` - Submit a signed transaction to the node.
      - ``available_networks`` - Get the list of NetworkIdentifiers supported by the Rosetta Server.
      - ``network_options`` - Get the version information and allowed network-speciifc types for a given network ID.
      - ``network_status`` - Get a given network's status.
      - ``account_balance`` - Get an account balance in a given network.
      - ``block`` - Get a block and its transactions by its ID in a given network.
      - ``block_transaction`` - Get a a transaction by its ID in a given network and block IDs.
      - ``mempool_transactions_rosetta`` - Get the list of transactions currently in the mempool of a given network.
      - ``mempool_transaction`` - Get a mempool transaction by its ID in a given network
      - ``signed_transaction_hash`` - Get a network-specific transaction hash for a signed transaction.
      - ``transaction_construction_metadata`` - Get the metadata for a transaction consturction.
      - ``search`` - Search anything in the blockchain - blocks, transactions, contracts or accounts by a hash or an ID.
      - ``recent_reward_slot_holders`` - Get the list of Bitcoin addresses that would receive PoX commitments
      - ``address_recent_reward_slot_holders`` - Get the list of Bitcoin addresses that would receive PoX commitments for a given recipient address
      - ``recent_reward_recipients`` - Get the list of recent burnchain reward recipients.
      - ``recipient_recent_rewards`` - Get the list of recent burnchain rewards for a given recipient
      - ``recipient_total_rewards`` - Get the list of total burnchain rewards for a given recipient


  ## Available params
      - All the parameters that are available in the Stacks API Docuemntation can be used here.
      - Required parameters must follow the snake_case naming scheme.
      - Optional parameters can be used as they are called in the Stacks API Docs.
  ## Returns

      Returns any of the following:
       - the return of the API Call
       - {:error, :missing_required_params, [list,of,missing,required,parameters]} - Returned without hitting the API when one of the API call's required parameters are missing.
       - {:error, :invalid_params} - Returned when the params input is not a map.
  """
  def request(string, params \\ %{})

  def request("account_balances", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/balances?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/stx?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/transactions?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/transactions_with_transfers?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/#{tx_id}/with_transfers?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/nonces?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/stx_inbound?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_assets", params) do
    node_base_url = Helpers.node_url()
    required_params = [:principal]

    case required_params_available?(params, required_params) do
      {true, params} ->
        principal = Map.get(params, :principal)
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{principal}/assets?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/#{principal}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block/#{hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block/by_height/#{hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block/by_burn_block_height/#{hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/block/by_burn_block_hash/#{hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
    required_params = [:tld]

    case required_params_available?(params, required_params) do
      {true, params} ->
        tld = Map.get(params, :tld)

        HttpClient.endpoint_get_callback(url <> "/v2/prices/namespaces/##{tld}")

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("namespaces", _params) do
    HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v1/namespaces")
  end

  def request("namespace_names", params) do
    url = Helpers.node_url()
    required_params = [:tld]

    case required_params_available?(params, required_params) do
      {true, params} ->
        tld = Map.get(params, :tld)
        query_params = params |> Helpers.format_query_params()

        HttpClient.endpoint_get_callback(url <> "/v1/namespaces/##{tld}/names?#{query_params}")

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/contract/#{contract_id}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/contract/#{contract_id}/events?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/contracts/interface/#{contract_address}/#{contract_name}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
          Map.drop(params, required_params)
          |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/map_entry/#{contract_address}/#{contract_name}/#{map_name}?#{query_params}"

        HttpClient.endpoint_post_callback(url, %{})

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/contracts/source/#{contract_address}/#{contract_name}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
          Map.drop(params, required_params)
          |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/v2/contracts/call-read/#{contract_address}/#{contract_name}/#{function_name}?#{query_params}"

        HttpClient.endpoint_post_callback(url, %{})

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx/block/#{block_hash}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/tx/block_height/#{block_height}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/address/#{address}/mempool?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

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

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("sign_transaction", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier, :unsigned_transaction, :signatures]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)
        unsigned_transaction = Map.get(params, :unsigned_transaction)
        signatures = Map.get(params, :signatures)

        url =
          node_base_url <>
            "/rosetta/v1/construction/combine"

        body = %{
          network_identifier: network_identifier,
          unsigned_transaction: unsigned_transaction,
          signatures: signatures
        }

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("submit_signed_transaction", params) do
    node_base_url = Helpers.node_url()
    required_params = [:signed_transaction, :network_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)
        signed_transaction = Map.get(params, :signed_transaction)

        url =
          node_base_url <>
            "/rosetta/v1/construction/submit"

        body = %{
          network_identifier: network_identifier,
          signed_transaction: signed_transaction
        }

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("available_networks", _params) do
    HttpClient.endpoint_post_callback(Helpers.node_url() <> "/rosetta/v1/network/list", %{})
  end

  def request("network_options", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)

        body =
          %{"network_identifier" => network_identifier}
          |> add_optional_param(params, :metadata)

        url =
          node_base_url <>
            "/rosetta/v1/network/options"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("network_status", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)

        body =
          %{"network_identifier" => network_identifier}
          |> add_optional_param(params, :metadata)

        url =
          node_base_url <>
            "/rosetta/v1/network/status"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("account_balance", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier, :account_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)
        account_identifier = Map.get(params, :account_identifier)

        body =
          %{
            "network_identifier" => network_identifier,
            "account_identifier" => account_identifier
          }
          |> add_optional_param(params, :block_identifier)

        url =
          node_base_url <>
            "/rosetta/v1/account/balance"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("block", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier, :block_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)
        block_identifier = Map.get(params, :block_identifier)

        body = %{
          "network_identifier" => network_identifier,
          "block_identifier" => block_identifier
        }

        url =
          node_base_url <>
            "/rosetta/v1/block"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("block_transaction", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier, :block_identifier, :transaction_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)
        block_identifier = Map.get(params, :block_identifier)
        transaction_identifier = Map.get(params, :transaction_identifier)

        body = %{
          "network_identifier" => network_identifier,
          "block_identifier" => block_identifier,
          "transaction_identifier" => transaction_identifier
        }

        url =
          node_base_url <>
            "/rosetta/v1/block/transaction"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("mempool_transactions_rosetta", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)

        body =
          %{
            "network_identifier" => network_identifier
          }
          |> add_optional_param(params, :metadata)

        url =
          node_base_url <>
            "/rosetta/v1/mempool"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("mempool_transaction", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier, :transaction_identifier]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)
        transaction_identifier = Map.get(params, :transaction_identifier)

        body = %{
          "transaction_identifier" => transaction_identifier,
          "network_identifier" => network_identifier
        }

        url =
          node_base_url <>
            "/rosetta/v1/mempool/transaction"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("signed_transaction_hash", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier, :signed_transaction]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)
        signed_transaction = Map.get(params, :signed_transaction)

        body = %{
          "network_identifier" => network_identifier,
          "signed_transaction" => signed_transaction
        }

        url =
          node_base_url <>
            "/rosetta/v1/construction/hash"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("transaction_construction_metadata", params) do
    node_base_url = Helpers.node_url()
    required_params = [:network_identifier, :options]

    case required_params_available?(params, required_params) do
      {true, params} ->
        network_identifier = Map.get(params, :network_identifier)
        options = Map.get(params, :options)

        body =
          %{
            "network_identifier" => network_identifier,
            "options" => options
          }
          |> add_optional_param(params, :public_key)

        url =
          node_base_url <>
            "/rosetta/v1/construction/metadata"

        HttpClient.endpoint_post_callback(url, body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("search", params) do
    node_base_url = Helpers.node_url()
    required_params = [:id]

    case required_params_available?(params, required_params) do
      {true, params} ->
        id = Map.get(params, :id)
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/search/#{id}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("recent_reward_slot_holders", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/burnchain/reward_slot_holders?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("address_recent_reward_slot_holders", params) do
    node_base_url = Helpers.node_url()
    required_params = [:address]

    case required_params_available?(params, required_params) do
      {true, params} ->
        address = Map.get(params, :address)
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/burnchain/reward_slot_holders/#{address}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("recent_reward_recipients", params) do
    node_base_url = Helpers.node_url()
    required_params = []

    case required_params_available?(params, required_params) do
      {true, params} ->
        query_params = params |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/burnchain/rewards?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("recipient_recent_rewards", params) do
    node_base_url = Helpers.node_url()
    required_params = [:address]

    case required_params_available?(params, required_params) do
      {true, params} ->
        address = Map.get(params, :address)
        query_params = Map.drop(params, required_params) |> Helpers.format_query_params()

        url =
          node_base_url <>
            "/extended/v1/burnchain/rewards/#{address}?#{query_params}"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def request("recipient_total_rewards", params) do
    node_base_url = Helpers.node_url()
    required_params = [:address]

    case required_params_available?(params, required_params) do
      {true, params} ->
        address = Map.get(params, :address)

        url =
          node_base_url <>
            "/extended/v1/burnchain/rewards/#{address}/total"

        HttpClient.endpoint_get_callback(url)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  # Left to do:
  # - Subscribe to events
end

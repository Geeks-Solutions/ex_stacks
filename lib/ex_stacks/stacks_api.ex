defmodule ExStacks.StacksAPI do
  @moduledoc """
  This module is responsible of communicating with the Stacks Blockchain

  Function param atom keys are the same as the [API Docs](https://docs.hiro.so/api), however they must be snake cased.
  """
  alias ExStacks.{Helpers, HttpClient, WebSocketClient}

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
      - account_balance - Get an account balance in a given network.
      - account_balances - Get Account Balances
      - account_information - Get the account information
      - account_nonces - Get the latest nonce used by an account
      - account_stx_balance - Get Account STX Balance
      - account_stx_inbound - Get the account inbound STX Transfers
      - account_transactions - Get Account Transactions
      - account_transactions_with_transfers - Get Account Transactions including STX Transfers for each transaction
      - account_transaction_by_id - Get Account Transaction information for a specific transaction
      - address_recent_reward_slot_holders - Get the list of Bitcoin addresses that would receive PoX commitments for a given recipient address
      - api_status - Get the API Status
      - available_networks - Get the list of NetworkIdentifiers supported by the Rosetta Server.
      - block - Get a block and its transactions by its ID in a given network.
      - block_by_burnchain_hash - Get a block by the given burnchain block hash
      - block_by_burnchain_height - Get a block by the given burnchain block height
      - block_by_hash - Get a block by its hash
      - block_by_height - Get a block by its height
      - block_transaction - Get a a transaction by its ID in a given network and block IDs.
      - circulating_stx_supply_plain_text - Get the circulating STX supply as plain text.
      - contracts_by_trait - Get the list of contracts based on specific traits.
      - contract_events - Get the events triggered by a contract.
      - contract_info - Get a contract information
      - contract_interface - Get a contract interface
      - contract_source - Get the contract Clarity source code.
      - core_api_info - Get the Core API information
      - details_for_transactions - Get a list of transactions using an array of the transaction IDs.
      - dropped_mempool_transactions - Get all recently broadcasted transactions to the mempool that have been dropped.
      - estimated_stx_transfer_transaction_fee - Get the estimated fee rate for STX Transfers
      - estimated_transaction_fee - Get the approximate fee for the supplied transaction.
      - ft_by_contract_id_metadata - Get the metadata for fungible tokens for a given contract ID.
      - fts_metadata - Get a list of fungible tokens with their metadata
      - given_network_block_time - Get the given network target block time.
      - legacy_stx_supply - Get the total and unlocked STX Supply with the results formatted for the legacy 1.0 API
      - mempool_transaction - Get a mempool transaction by its ID in a given network
      - mempool_transactions - Get all recently broadcasted transactions to the mempool.
      - mempool_transactions_rosetta - Get the list of transactions currently in the mempool of a given network.
      - microblock - Get a microblock by its hash.
      - names - Get all the names that are known to the target node.
      - namespace_price - Get the price of a specific namespace
      - name_price - Get the price of a specific name
      - namespaces - Get all namespaces
      - namespace_names - Get all names that belong to a specific namespace
      - name_details - Get the details of a specific name.
      - name_subdomains - Get the subdomains of a name.
      - name_zonefile - Get the zonefile of a name.
      - name_historical_zonefile - Get the historical zonefile of a name.
      - names_owned_by_address - Get all the names owned by a specific address.
      - network_block_time - Get a network target block time
      - network_options - Get the version information and allowed network-speciifc types for a given network ID.
      - network_status - Get a given network status.
      - nfts_metadata - Get a list of NFTs with their metadata
      - nft_holdings - Get all the NFT owned by a given address.
      - nft_history - Get all the relevant events for a given NFT.
      - nft_mints - Get all the mint events for a specific NFT asset class.
      - nft_by_contract_id_metadata - Get the metadata for NFTs belonging to a contract ID.
      - proof_of_transfer_details - Get PoX information.
      - raw_transaction - Get a raw transaction by its ID. (hex encoded)
      - recent_reward_slot_holders - Get the list of Bitcoin addresses that would receive PoX commitments
      - recent_reward_recipients - Get the list of recent burnchain reward recipients.
      - recipient_recent_rewards - Get the list of recent burnchain rewards for a given recipient
      - recipient_total_rewards - Get the list of total burnchain rewards for a given recipient
      - read_only_function - Call a read-only public function in a specific smart contract.
      - recent_transactions - Get the list of recently mined transactions.
      - recent_blocks - Get the list of recently mined blocks
      - recent_microblocks - Get the recent microblocks details.
      - search - Search anything in the blockchain - blocks, transactions, contracts or accounts by a hash or an ID.
      - signed_transaction_hash - Get a network-specific transaction hash for a signed transaction.
      - sign_transaction - Returns the signed transaction version of an unsigned transaction payload.
      - specific_data_map_in_contract - Get a contract data from a specific data map.
      - stx_supply - Get the total and unlocked STX Supply
      - submit_signed_transaction - Submit a signed transaction to the node.
      - total_stx_supply_plain_text - Get the total STX supply as plain text
      - transaction_construction_metadata - Get the metadata for a transaction consturction.
      - transactions_by_block_hash - Get all transactions in a mined block by the block hash.
      - transactions_by_block_height - Get all transactions in a mined block by the block height.
      - transactions_by_address - Get all the transactions for a given address that are currently in the mempool.
      - transaction_events - Get a list of transaction events.
      - transaction - Get a transaction by its ID.
      - transactions_in_unanchored_microblocks - Get the list of transactions that belong to an unanchored microblock.


  ## Available params
      - All the parameters that are available in the Stacks API Docuemntation can be used here.
      - Required parameters must follow the snake_case naming scheme.
      - Optional parameters can be used as they are called in the Stacks API Docs.
  ## Returns

      Returns any of the following:
       - the return of the API Call
       - {:error, :missing_required_params, [list,of,missing,required,parameters]} - Returned without hitting the API when one of the API call required parameters are missing.
       - {:error, :invalid_params} - Returned when the params input is not a map.
       - {:error, :unexpected_name} - Returned when the request name is not supported.
  """
  def request(string, params \\ %{})

  def request("account_balances" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("account_stx_balance" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("account_transactions" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("account_transactions_with_transfers" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("account_transaction_by_id" = action, params),
    do: validate_and_request(:get, action, params, [:principal, :tx_id])

  def request("account_nonces" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("account_stx_inbound" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("account_assets" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("account_information" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("recent_blocks" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("block_by_hash" = action, params),
    do: validate_and_request(:get, action, params, [:hash])

  def request("block_by_height" = action, params),
    do: validate_and_request(:get, action, params, [:height])

  def request("block_by_burnchain_height" = action, params),
    do: validate_and_request(:get, action, params, [:burn_block_height])

  def request("block_by_burnchain_hash" = action, params),
    do: validate_and_request(:get, action, params, [:burn_block_hash])

  def request("estimated_stx_transfer_transaction_fee" = action, _params) do
    HttpClient.endpoint_get_callback(url(action, %{}))
  end

  def request("estimated_transaction_fee" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:transaction_payload],
      [:transaction_payload],
      [:estimated_len]
    )
  end

  def request("fts_metadata" = action, params), do: validate_and_request(:get, action, params, [])

  def request("ft_by_contract_id_metadata" = action, params),
    do: validate_and_request(:get, action, params, [:contract_id])

  def request("core_api_info", _params),
    do: HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v2/info")

  def request("api_status", _params),
    do: HttpClient.endpoint_get_callback(Helpers.node_url() <> "/extended/v1/status")

  def request("network_block_time", _params),
    do:
      HttpClient.endpoint_get_callback(
        Helpers.node_url() <> "/extended/v1/info/network_block_times"
      )

  def request("proof_of_transfer_details", _params),
    do: HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v2/pox")

  def request("given_network_block_time" = action, params),
    do: validate_and_request(:get, action, params, [:network])

  def request("stx_supply" = action, params), do: validate_and_request(:get, action, params, [])

  def request("legacy_stx_supply" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("total_stx_supply_plain_text", _params),
    do:
      HttpClient.endpoint_get_callback(
        Helpers.node_url() <> "/extended/v1/stx_supply/total/plain"
      )

  def request("circulating_stx_supply_plain_text", _params),
    do:
      HttpClient.endpoint_get_callback(
        Helpers.node_url() <> "/extended/v1/stx_supply/circulating/plain"
      )

  def request("recent_microblocks" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("microblock" = action, params),
    do: validate_and_request(:get, action, params, [:hash])

  def request("transactions_in_unanchored_microblocks", _params),
    do:
      HttpClient.endpoint_get_callback(
        Helpers.node_url() <> "/extended/v1/microblock/unanchored/txs"
      )

  def request("namespace_price" = action, params),
    do: validate_and_request(:get, action, params, [:tld])

  def request("name_price" = action, params),
    do: validate_and_request(:get, action, params, [:name])

  def request("namespaces", _params),
    do: HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v1/namespaces")

  def request("namespace_names" = action, params),
    do: validate_and_request(:get, action, params, [:tld])

  def request("names", _params),
    do: HttpClient.endpoint_get_callback(Helpers.node_url() <> "/v1/names")

  def request("name_details" = action, params),
    do: validate_and_request(:get, action, params, [:name])

  def request("name_subdomains" = action, params),
    do: validate_and_request(:get, action, params, [:name])

  def request("name_zonefile" = action, params),
    do: validate_and_request(:get, action, params, [:name])

  def request("name_historical_zonefile" = action, params),
    do: validate_and_request(:get, action, params, [:name, :zonefile_hash])

  def request("names_owned_by_address" = action, params),
    do: validate_and_request(:get, action, params, [:blockchain, :address])

  def request("nft_holdings" = action, params),
    do: validate_and_request(:get, action, params, [:principal])

  def request("nft_history" = action, params),
    do: validate_and_request(:get, action, params, [:asset_identifier, :value])

  def request("nft_mints" = action, params),
    do: validate_and_request(:get, action, params, [:asset_identifier])

  def request("nfts_metadata" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("nft_by_contract_id_metadata" = action, params),
    do: validate_and_request(:get, action, params, [:contract_id])

  def request("contract_info" = action, params),
    do: validate_and_request(:get, action, params, [:contract_id])

  def request("contracts_by_trait" = action, params),
    do: validate_and_request(:get, action, params, [:trait_abi])

  def request("contract_events" = action, params),
    do: validate_and_request(:get, action, params, [:contract_id])

  def request("contract_interface" = action, params),
    do: validate_and_request(:get, action, params, [:contract_address, :contract_name])

  def request("specific_data_map_in_contract" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:contract_address, :contract_name, :map_name],
      [],
      []
    )
  end

  def request("contract_source" = action, params),
    do: validate_and_request(:get, action, params, [:contract_address, :contract_name])

  def request("read_only_function" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:contract_address, :contract_name, :function_name, :sender, :arguments],
      [:sender, :arguments],
      []
    )
  end

  def request("recent_transactions" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("mempool_transactions" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("dropped_mempool_transactions" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("details_for_transactions" = action, params),
    do: validate_and_request(:get, action, params, [:tx_id])

  def request("transaction" = action, params),
    do: validate_and_request(:get, action, params, [:tx_id])

  def request("raw_transaction" = action, params),
    do: validate_and_request(:get, action, params, [:tx_id])

  def request("transactions_by_block_hash" = action, params),
    do: validate_and_request(:get, action, params, [:block_hash])

  def request("transactions_by_block_height" = action, params),
    do: validate_and_request(:get, action, params, [:block_height])

  def request("transactions_by_address" = action, params),
    do: validate_and_request(:get, action, params, [:address])

  def request("transaction_events" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("sign_transaction" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier, :unsigned_transaction, :signatures],
      [:network_identifier, :unsigned_transaction, :signatures],
      []
    )
  end

  def request("submit_signed_transaction" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:signed_transaction, :network_identifier],
      [:signed_transaction, :network_identifier],
      []
    )
  end

  def request("available_networks", _params),
    do: HttpClient.endpoint_post_callback(Helpers.node_url() <> "/rosetta/v1/network/list", %{})

  def request("network_options" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier],
      [:network_identifier],
      [:metadata]
    )
  end

  def request("network_status" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier],
      [:network_identifier],
      [:metadata]
    )
  end

  def request("account_balance" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier, :account_identifier],
      [:network_identifier, :account_identifier],
      [:block_identifier]
    )
  end

  def request("block" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier, :block_identifier],
      [:network_identifier, :block_identifier],
      []
    )
  end

  def request("block_transaction" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier, :block_identifier, :transaction_identifier],
      [:network_identifier, :block_identifier, :transaction_identifier],
      []
    )
  end

  def request("mempool_transactions_rosetta" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier],
      [:network_identifier],
      [:metadata]
    )
  end

  def request("mempool_transaction" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier, :transaction_identifier],
      [:network_identifier, :transaction_identifier],
      [:metadata]
    )
  end

  def request("signed_transaction_hash" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier, :signed_transaction],
      [:network_identifier, :signed_transaction],
      []
    )
  end

  def request("transaction_construction_metadata" = action, params) do
    validate_and_request(
      :post,
      action,
      params,
      [:network_identifier, :options],
      [:network_identifier, :options],
      [:public_key]
    )
  end

  def request("search" = action, params), do: validate_and_request(:get, action, params, [:id])

  def request("recent_reward_slot_holders" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("address_recent_reward_slot_holders" = action, params),
    do: validate_and_request(:get, action, params, [:address])

  def request("recent_reward_recipients" = action, params),
    do: validate_and_request(:get, action, params, [])

  def request("recipient_recent_rewards" = action, params),
    do: validate_and_request(:get, action, params, [:address])

  def request("recipient_total_rewards" = action, params),
    do: validate_and_request(:get, action, params, [:address])

  def request(_, _) do
    {:error, :unsupported_name}
  end

  @doc """
    Used to subscribe to Stacks WebSocket Server events.

  ## Available Events with their parameters:

      - block, no parameters - Subscribes to newly mined block events
      - microblock, no parameters - Subscribes to newly streamed microblocks events
      - mempool, no parameters - Subscribes to new transaction added to mempool events
      - tx_updates, parameters: :tx_id - Subscribes to new updates to this specific transaction
      - address_tx_updates, parameters: :address - Subscribes to new updates to transactions for this specific address
      - address_balance_update, parameters: :address - Subscribes to new updates to this specific address balance

  ## Returns

      Returns an :ok confirming the message has been relayed.

  ## How it works
    - All events require atleast one host project process to be present in ExStacks WebSocketClient process list.
    - All events will be relayed to all the processes, therefore you will need to pattern match the event youd like to handle
    - The format of an event will be a tuple, the first element(s) of the tuple will be to identify the event:
      - {:block, event}
      - {:microblock, event}
      - {:mempool, event}
      - {:tx_update, event}
      - {:address_tx_update, event}
      - {:address_balance_update, event}
    - To register a new process to receive events, include in the subscription parameters the key/value pair: %{pid: #PID<1.2.3>}

  """
  def subscribe(method, params \\ %{})

  def subscribe("block", params) when is_map(params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{method: "subscribe", event: "block"}),
      Helpers.format_subscription_metadata("subscribe", params)
    )
  end

  def subscribe("microblock", params) when is_map(params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{method: "subscribe", event: "microblock"}),
      Helpers.format_subscription_metadata("subscribe", params)
    )
  end

  def subscribe("mempool", params) when is_map(params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{method: "subscribe", event: "mempool"}),
      Helpers.format_subscription_metadata("subscribe", params)
    )
  end

  def subscribe("tx_update", %{tx_id: transaction_id} = params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{
        method: "subscribe",
        event: "tx_update",
        tx_id: transaction_id
      }),
      Helpers.format_subscription_metadata("subscribe", params)
    )
  end

  def subscribe("address_tx_update", %{address: address} = params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{
        method: "subscribe",
        event: "address_tx_update",
        address: address
      }),
      Helpers.format_subscription_metadata("subscribe", params)
    )
  end

  def subscribe("address_balance_update", %{address: address} = params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{
        method: "subscribe",
        event: "address_balance_update",
        address: address
      }),
      Helpers.format_subscription_metadata("subscribe", params)
    )
  end

  def subscribe(_, _), do: {:error, :invalid_input}

  @doc """
    Used to unsubscribe from Stacks WebSocket Server events.

  ## Available Events with their parameters:

      - block, no parameters - Unsubscribes from newly mined block events
      - microblock, no parameters - Unsubscribes from newly streamed microblocks events
      - mempool, no parameters - Unsubscribes from new transaction added to mempool events
      - tx_updates, parameters: :tx_id - Unsubscribes from new updates to this specific transaction
      - address_tx_updates, parameters: :address - Unsubscribes from new updates to transactions for this specific address
      - address_balance_update, parameters: :address - Unsubscribes from new updates to this specific address balance

  ## Returns

      Returns an :ok confirming the message has been relayed.

  ## How it works
    - To unregister a process to stop receiving events on it, include in the unsubscription parameters the key/value pair: %{pid: #PID<1.2.3>}
  """
  def unsubscribe(method, params \\ %{})

  def unsubscribe("block", params) when is_map(params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{method: "unsubscribe", event: "block"}),
      Helpers.format_subscription_metadata("unsubscribe", params)
    )
  end

  def unsubscribe("microblock", params) when is_map(params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{method: "unsubscribe", event: "microblock"}),
      Helpers.format_subscription_metadata("unsubscribe", params)
    )
  end

  def unsubscribe("mempool", params) when is_map(params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{method: "unsubscribe", event: "mempool"}),
      Helpers.format_subscription_metadata("unsubscribe", params)
    )
  end

  def unsubscribe("tx_update", %{tx_id: transaction_id} = params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{
        method: "unsubscribe",
        event: "tx_update",
        tx_id: transaction_id
      }),
      Helpers.format_subscription_metadata("unsubscribe", params)
    )
  end

  def unsubscribe("address_tx_update", %{address: address} = params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{
        method: "unsubscribe",
        event: "address_tx_update",
        address: address
      }),
      Helpers.format_subscription_metadata("unsubscribe", params)
    )
  end

  def unsubscribe("address_balance_update", %{address: address} = params) do
    WebSocketClient.send_frame(
      Helpers.format_websocket_frame(%{
        method: "unsubscribe",
        event: "address_balance_update",
        address: address
      }),
      Helpers.format_subscription_metadata("unsubscribe", params)
    )
  end

  def unsubscribe(_, _), do: {:error, :invalid_input}

  defp validate_and_request(:get, action, params, required_params) do
    case required_params_available?(params, required_params) do
      {true, params} ->
        HttpClient.endpoint_get_callback(url(action, params))

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  defp validate_and_request(
         :post,
         action,
         params,
         required_params,
         required_body_params,
         optional_body_params
       ) do
    case required_params_available?(params, required_params) do
      {true, params} ->
        body =
          Enum.reduce(required_body_params, %{}, fn required_param, acc ->
            Map.merge(acc, %{Atom.to_string(required_param) => Map.get(params, required_param)})
          end)

        body =
          Enum.reduce(optional_body_params, body, fn optional_param, acc ->
            acc |> add_optional_param(params, optional_param)
          end)

        HttpClient.endpoint_post_callback(url(action, params), body)

      {false, missing_params} ->
        {:error, :missing_required_params, missing_params}

      false ->
        {:error, :invalid_params}
    end
  end

  def url(action, params \\ %{}) do
    urls = %{
      "account_balances" =>
        "/extended/v1/address/#{Map.get(params, :principal)}/balances?#{query_params(params, [:principal])}",
      "account_stx_balance" =>
        "/extended/v1/address/#{Map.get(params, :principal)}/stx?#{query_params(params, [:principal])}",
      "account_transactions" =>
        "/extended/v1/address/#{Map.get(params, :principal)}/transactions?#{query_params(params, [:principal])}}",
      "account_transactions_with_transfers" =>
        "/extended/v1/address/#{Map.get(params, :principal)}/transactions_with_transfers?#{query_params(params, [:principal])}}",
      "account_transaction_by_id" =>
        "/extended/v1/address/#{Map.get(params, :principal)}/#{Map.get(params, :tx_id)}/with_transfers?#{query_params(params, [:principal, :tx_id])}",
      "account_nonces" =>
        "/extended/v1/address/#{Map.get(params, :principal)}/nonces?#{query_params(params, [:principal])}",
      "account_stx_inbound" =>
        "/extended/v1/address/#{Map.get(params, :principal)}/stx_inbound?#{query_params(params, [:principal])}",
      "account_assets" =>
        "/extended/v1/address/#{Map.get(params, :principal)}/assets?#{query_params(params, [:principal])}",
      "account_information" =>
        "/v2/accounts/#{Map.get(params, :principal)}?#{query_params(params, [:principal])}",
      "recent_blocks" => "/extended/v1/block?#{query_params(params, [])}",
      "block_by_hash" =>
        "/extended/v1/block/#{Map.get(params, :hash)}?#{query_params(params, [:hash])}",
      "block_by_height" =>
        "/extended/v1/block/by_height/#{Map.get(params, :height)}?#{query_params(params, [:height])}",
      "block_by_burnchain_height" =>
        "/extended/v1/block/by_burn_block_height/#{Map.get(params, :burn_block_height)}?#{query_params(params, [:burn_block_height])}",
      "block_by_burnchain_hash" =>
        "/extended/v1/block/by_burn_block_hash/#{Map.get(params, :burn_block_hash)}?#{query_params(params, [:burn_block_hash])}",
      "estimated_stx_transfer_transaction_fee" => "/v2/fees/transfer",
      "fts_metadata" => "/extended/v1/tokens/ft/metadata?#{query_params(params, [])}",
      "ft_by_contract_id_metadata" =>
        "/extended/v1/tokens/#{Map.get(params, :contract_id)}/ft/metadata",
      "given_network_block_time" =>
        "/extended/v1/info/network_block_time/#{Map.get(params, :network)}",
      "stx_supply" => "/extended/v1/stx_supply?#{query_params(params, [])}",
      "legacy_stx_supply" => "/extended/v1/stx_supply/legacy_format?#{query_params(params, [])}",
      "recent_microblocks" => "/extended/v1/microblock?#{query_params(params, [])}",
      "microblock" => "/extended/v1/microblock/#{Map.get(params, :hash)}",
      "namespace_price" => "/v2/prices/namespaces/#{Map.get(params, :tld)}",
      "name_price" => "/v2/prices/names/#{Map.get(params, :name)}",
      "namespace_names" =>
        "/v1/namespaces/#{Map.get(params, :tld)}/names?#{query_params(params, [:tld])}",
      "name_details" => "/v1/names/#{Map.get(params, :name)}",
      "name_subdomains" => "/v1/names/#{Map.get(params, :name)}/subdomains",
      "name_zonefile" => "/v1/names/#{Map.get(params, :name)}/zonefile",
      "name_historical_zonefile" =>
        "/v1/names/#{Map.get(params, :name)}/zonefile/#{Map.get(params, :zonefile_hash)}",
      "names_owned_by_address" =>
        "/v1/addresses/#{Map.get(params, :blockchain)}/#{Map.get(params, :address)}",
      "nft_holdings" => "/extended/v1/tokens/nft/holdings?#{query_params(params, [])}",
      "nft_history" => "/extended/v1/tokens/nft/history?#{query_params(params, [])}",
      "nft_mints" => "/extended/v1/tokens/nft/mints?#{query_params(params, [])}",
      "nfts_metadata" => "/extended/v1/tokens/nft/metadata?#{query_params(params, [])}",
      "nft_by_contract_id_metadata" =>
        "/extended/v1/tokens/#{Map.get(params, :contract_id)}/nft/metadata",
      "contract_info" =>
        "/extended/v1/contract/#{Map.get(params, :contract_id)}?#{query_params(params, [:contract_id])}",
      "contracts_by_trait" => "/extended/v1/contract/by_trait?#{query_params(params, [])}",
      "contract_events" =>
        "/extended/v1/contract/#{Map.get(params, :contract_id)}/events?#{query_params(params, [:contract_id])}",
      "contract_interface" =>
        "/v2/contracts/interface/#{Map.get(params, :contract_address)}/#{Map.get(params, :contract_name)}?#{query_params(params, [:contract_address, :contract_name])}",
      "contract_source" =>
        "/v2/contracts/source/#{Map.get(params, :contract_address)}/#{Map.get(params, :contract_name)}?#{query_params(params, [:contract_address, :contract_name])}",
      "recent_transactions" => "/extended/v1/tx?#{query_params(params, [])}",
      "mempool_transactions" => "/extended/v1/tx/mempool?#{query_params(params, [])}",
      "dropped_mempool_transactions" =>
        "/extended/v1/tx/mempool/dropped?#{query_params(params, [])}",
      "details_for_transactions" => "/extended/v1/tx/multiple?#{query_params(params, [])}",
      "transaction" => "/extended/v1/tx/#{Map.get(params, :tx_id)}",
      "raw_transaction" => "/extended/v1/tx/#{Map.get(params, :tx_id)}/raw",
      "transactions_by_block_hash" =>
        "/extended/v1/tx/block/#{Map.get(params, :block_hash)}?#{query_params(params, [:block_hash])}",
      "transactions_by_block_height" =>
        "/extended/v1/tx/block_height/#{Map.get(params, :block_height)}?#{query_params(params, [:block_height])}",
      "transactions_by_address" =>
        "/extended/v1/address/#{Map.get(params, :address)}/mempool?#{query_params(params, [:address])}",
      "transaction_events" => "/extended/v1/tx/events?#{query_params(params, [])}",
      "search" => "/extended/v1/search/#{Map.get(params, :id)}?#{query_params(params, [:id])}",
      "recent_reward_slot_holders" =>
        "/extended/v1/burnchain/reward_slot_holders?#{query_params(params, [])}",
      "address_recent_reward_slot_holders" =>
        "/extended/v1/burnchain/reward_slot_holders/#{Map.get(params, :address)}?#{query_params(params, [:address])}",
      "recent_reward_recipients" => "/extended/v1/burnchain/rewards?#{query_params(params, [])}",
      "recipient_recent_rewards" =>
        "/extended/v1/burnchain/rewards/#{Map.get(params, :address)}?#{query_params(params, [:address])}",
      "recipient_total_rewards" =>
        "/extended/v1/burnchain/rewards/#{Map.get(params, :address)}/total",
      "transaction_construction_metadata" => "/rosetta/v1/construction/metadata",
      "signed_transaction_hash" => "/rosetta/v1/construction/hash",
      "estimated_transaction_fee" => "/v2/fees/transaction",
      "specific_data_map_in_contract" =>
        "/v2/map_entry/#{Map.get(params, :contract_address)}/#{Map.get(params, :contract_name)}/#{Map.get(params, :map_name)}?#{query_params(params, [:contract_address, :contract_name, :map_name])}",
      "read_only_function" =>
        "/v2/contracts/call-read/#{Map.get(params, :contract_address)}/#{Map.get(params, :contract_name)}/#{Map.get(params, :function_name)}?#{query_params(params, [:contract_address, :contract_name, :function_name])}",
      "sign_transaction" => "/rosetta/v1/construction/combine",
      "submit_signed_transaction" => "/rosetta/v1/construction/submit",
      "network_options" => "/rosetta/v1/network/options",
      "network_status" => "/rosetta/v1/network/status",
      "account_balance" => "/rosetta/v1/account/balance",
      "block" => "/rosetta/v1/block",
      "block_transaction" => "/rosetta/v1/block/transaction",
      "mempool_transactions_rosetta" => "/rosetta/v1/mempool",
      "mempool_transaction" => "/rosetta/v1/mempool/transaction"
    }

    Helpers.node_url() <> Map.get(urls, action)
  end

  defp query_params(params, []) do
    params |> Helpers.format_query_params()
  end

  defp query_params(params, neglected_fields) do
    Map.drop(params, neglected_fields) |> Helpers.format_query_params()
  end
end

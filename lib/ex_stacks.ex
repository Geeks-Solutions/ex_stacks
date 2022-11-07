defmodule ExStacks do
  @moduledoc """
  ExStacks is a library that acts as a middle layer between your host project and Stacks Blockchain.
  It has multiple implemented features:
  - Read data from the blockchain
  - Sign a transaction
  - Submit a transaction
  - Subscribe to blockchain websocket events
  - Unsubscribe from blockchain websocket events

  To configure the library:
  1. Add ex_stacks to you `mix.exs`
  2. Retrieve your desired node base URL - `required`
  3. In case you want to receive event updates directly from the blockchain through the websocket, you need the websocket base url - `optional`
  4. Add the following config to your configuration file:
  ```elixir
  config :ex_stacks,
  node_url: "your_node_url",
  node_ws_url: "your_optional_node_websocket_url"
  ```

  - You can use [Hiro](https://docs.hiro.so/get-started/stacks-blockchain-api)'s mainnet or testnet node URLs in case you do not have your own node access
  """
end

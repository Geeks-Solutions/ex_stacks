## ExStacks

# Introduction

ExStacks is a library that serves as a interface to integrate Stacks Blockchain into your project.

# Setup

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

# Usage

As of now, the following Stacks Blockchain API actions are supported:
- All websocket events through the ``ExStacks.StacksAPI.subscribe/2`` and ``ExStacks.StacksAPI.unsubscribe/2`` function.
- All Get API calls through the ``ExStacks.StacksAPI.request/2`` function.
- Submitting a signed transaction through the ``ExStacks.StacksAPI.request/2`` function.
- Signing a transaction through the ``ExStacks.StacksAPI.request/2`` function.

You can retrieve the process listening to the websocket events ID through ``ExStacks.WebSocketClient.get_process_id/0``, and implement it in any way you want.
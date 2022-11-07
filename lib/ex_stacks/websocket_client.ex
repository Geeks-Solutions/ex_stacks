defmodule ExStacks.WebSocketClient do
  @moduledoc """
  This module handles all the connections, messaging, handling the messages that are sent and received from the Stacks WebSocket server.
  """
  @moduledoc false

  use WebSockex
  require Logger
  alias ExStacks.Helpers

  def start_link(url, state \\ []) do
    WebSockex.start_link(url, __MODULE__, state, name: __MODULE__)
  end

  def send_frame(frame, %{event: event, pid: pid}) do
    start_child_if_not_started()

    cond do
      is_pid(pid) and event == "subscribe" ->
        # add pid to the list of pids subscribed to watch for events

        :ets.insert(
          :subscribed_processes,
          {:processes, (get_process_list() ++ [pid]) |> Enum.uniq()}
        )

      is_pid(pid) and event == "unsubscribe" ->
        # remove pid from the list of pids subscribed to watch for events

        :ets.insert(
          :subscribed_processes,
          {:processes, get_process_list() -- [pid]}
        )

      true ->
        # do nothing
        nil
    end

    WebSockex.send_frame(
      __MODULE__,
      {:text, frame}
    )
  end

  defp get_process_list do
    case :ets.lookup(:subscribed_processes, :processes) do
      [] -> []
      [{:processes, list}] -> list
    end
  end

  defp start_child_if_not_started do
    if Enum.any?(DynamicSupervisor.which_children(ExStacks.DynamicSupervisor), fn
         {_, _, _, [ExStacks.WebSocketClient]} ->
           true

         _ ->
           false
       end) do
      nil
    else
      DynamicSupervisor.start_child(
        ExStacks.DynamicSupervisor,
        {ExStacks.WebSocketClient, Helpers.node_ws_url()}
      )
    end
  end

  @impl WebSockex
  def handle_connect(_connection_status_map, state) do
    Logger.info("You have connected to Stacks WebSocket Server.")
    {:ok, state}
  end

  @impl WebSockex
  @doc false
  def handle_disconnect(_connection_status_map, state) do
    Logger.warn("You have disconnected from Stacks WebSocket Server.")
    {:ok, state}
  end

  @impl WebSockex
  @doc false
  def handle_frame({:text, msg}, state) do
    case Poison.decode!(msg) do
      %{"method" => method} = message ->
        Enum.each(get_process_list(), fn process ->
          send(process, {method |> String.to_atom(), message})
        end)

      _message ->
        # subscribtion and unsusbcription events
        nil
    end

    {:ok, state}
  end

  @doc """
    Returns the Process ID of the WebSocketClient module.
    You need to use this to handle received events however you want.
    - Events that have the "id" key in the json map top level keys are replies to the subscription / unsubscription events, and you can ignore these.
    - Events that do not have the "id" key are events dispatched from the Stacks WebSocket Server
    - An example of a newly mined block event:
      ```
      %{
  "jsonrpc" => "2.0",
  "method" => "block",
  "params" => %{
    "burn_block_hash" => "0x000000000000001349b2b3ede76f0f6262aa98279254486161b100b13ab2426d",
    "burn_block_height" => 2345830,
    "burn_block_time" => 1662640145,
    "burn_block_time_iso" => "2022-09-08T12:29:05.000Z",
    "canonical" => true,
    "execution_cost_read_count" => 4,
    "execution_cost_read_length" => 8165,
    "execution_cost_runtime" => 13810,
    "execution_cost_write_count" => 0,
    "execution_cost_write_length" => 0,
    "hash" => "0x798fa5d4cbf02a905f6cd0f9add0a92e63d47e1a37c86c25701817881c6eea97",
    "height" => 74280,
    "index_block_hash" => "0xddf30be5cfd7b5060889757e2fdccad6a739ce09af82f9b7b2e51c53b246d985",
    "microblocks_accepted" => ["0xde90b986fe1a26dcd281f8e69519a3b6cbe39c16f4a6dfe31cbe77e134509f65",
     "0x98be918d0f0dc99d5bf2d6a09e5d316d48ff260fc8c3835a6f911239e8fe3e1d"],
    "microblocks_streamed" => [],
    "miner_txid" => "0x41f3975a257b594de71e90eec144711c426e4f6fd8c5e3fd0046f38542df7690",
    "parent_block_hash" => "0x04171ef5b08e5583906279a5f3418c0192334a2128ebe43428eda58947d71f9d",
    "parent_microblock_hash" => "0xde90b986fe1a26dcd281f8e69519a3b6cbe39c16f4a6dfe31cbe77e134509f65",
    "parent_microblock_sequence" => 1,
    "txs" => ["0x7323b864251377f3936c90bbd69727dd87c48a981f75629bcba55e2ae1a4b4b3",
     "0x5203f3f414e984ef838bb0d4b7d90a9b34bcd1b5cadacf9c4791d61bf369f622",
     "0xa6a04715e911784d23993d92b9e75755a643c8a6016bae64720949c4c86a3135"]
  }
  }
  ```

  ## Returns

      Returns either:
        - {:ok, PID}
        - {:error, :websocket_client_not_started}
  """
  def get_process_id do
    case Enum.find(DynamicSupervisor.which_children(ExStacks.DynamicSupervisor), fn
           {_, _, _, [ExStacks.WebSocketClient]} ->
             true

           _ ->
             false
         end) do
      nil ->
        {:error, :websocket_client_not_started}

      {_, pid, _, _} ->
        {:ok, pid}
    end
  end
end

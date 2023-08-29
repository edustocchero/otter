defmodule Otter.Acceptor do
  @moduledoc """
  This module handles upcoming tcp connections.
  """
  use GenServer
  alias Otter.Packet.Request, as: Request

  def start_link(listener) do
    GenServer.start_link(__MODULE__, listener, [])
  end

  def init(listener) do
    GenServer.cast(self(), :accept)
    {:ok, listener}
  end

  def handle_cast(:accept, listener) do
    {:ok, _socket} = :gen_tcp.accept(listener)
    Otter.TcpPool.start_child(listener)
    {:noreply, listener}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :stopped, state}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_info({:tcp, socket, packet}, state) do
    Request.handle(packet) |> IO.inspect()
    :gen_tcp.send(socket, <<42>>)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    IO.puts("Closing socket")
    {:stop, :normal, state}
  end
end

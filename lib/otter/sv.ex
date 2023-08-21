defmodule Otter.Sv do
  @moduledoc """
  This module handles upcoming tcp connections.
  """
  use GenServer

  def start_link(listener) do
    GenServer.start_link(__MODULE__, listener, [])
  end

  def test_req() do
    {:ok, socket} =
      :gen_tcp.connect(
        {127, 0, 0, 1},
        8080,
        [:binary, packet: 2, active: false]
      )

    :ok = :gen_tcp.send(socket, <<42>>)
    {:ok, _resp} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    :ok
  end

  def init(listener) do
    GenServer.cast(self(), :accept)
    {:ok, listener}
  end

  def handle_cast(:accept, listener) do
    {:ok, _socket} = :gen_tcp.accept(listener)
    Otter.DynSup.start_child(listener)
    {:noreply, listener}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :stopped, state}
  end

  def handle_call(_request, _from, state) do
    {:reply, :ok, state}
  end

  def handle_info({:tcp, socket, <<42>>}, state) do
    IO.puts("Received a request")
    :gen_tcp.send(socket, <<42>>)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    IO.puts("Closing socket")
    {:stop, :normal, state}
  end
end

defmodule Otter.Client do
  @tcp_addr {127, 0, 0, 1}
  @tcp_port 8080
  @tcp_opts [:binary, packet: 2, active: false]

  def send_heartbeat(), do: send(<<42>>)

  def send_get(name) do
    name_length = byte_size(name)
    header = <<43, name_length::8>>
    packet = <<header::binary, name::binary>>
    send(packet)
  end

  defp send(bin) do
    {:ok, socket} = :gen_tcp.connect(@tcp_addr, @tcp_port, @tcp_opts)
    :ok = :gen_tcp.send(socket, bin)
    {:ok, _resp} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    :ok
  end
end

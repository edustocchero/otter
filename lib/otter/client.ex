defmodule Otter.Client do
  import :erlang, only: [term_to_binary: 1]

  @tcp_addr {127, 0, 0, 1}
  @tcp_port 8080
  @tcp_opts [:binary, packet: 2, active: false]

  @heartbeat 42
  @get 43
  @set 44
  @forget 45

  def send(:heartbeat), do: send_packet(<<@heartbeat>>)

  def send({:get, name: name}), do: send_get(name)

  def send({:set, name: name, payload: payload}), do: send_set(name, payload)

  def send({:forget, name: name}), do: send_forget(name)

  defp send_get(name) do
    name_length = byte_size(name)
    header = <<@get, name_length::8>>

    packet = <<header::binary, name::binary>>
    send_packet(packet)
  end

  defp send_set(name, payload) do
    name_length = byte_size(name)
    header = <<@set, name_length::8, name::binary>>

    binary_payload = term_to_binary(payload)
    payload_length = byte_size(binary_payload)

    packet_payload = <<payload_length::16, binary_payload::binary>>

    packet = <<header::binary, packet_payload::binary>>
    send_packet(packet)
  end

  defp send_forget(name) do
    name_length = byte_size(name)

    packet = <<@forget, name_length::8, name::binary>>
    send_packet(packet)
  end

  defp send_packet(packet) do
    {:ok, socket} = :gen_tcp.connect(@tcp_addr, @tcp_port, @tcp_opts)
    :ok = :gen_tcp.send(socket, packet)
    {:ok, _resp} = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)
    :ok
  end
end

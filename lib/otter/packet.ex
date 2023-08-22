defmodule Otter.Packet do
  def handle_packet(<<42>>) do
    IO.puts("Received a heartbeat")
    {:ok, :heartbeat}
  end

  def handle_packet(<<43, rest::binary>>), do: handle_get(rest)

  defp handle_get(<<length::8, name::binary-size(length)>>) do
    IO.puts("Received a get '#{name}' request")
    {:ok, name: name}
  end
end

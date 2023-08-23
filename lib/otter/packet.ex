defmodule Otter.Packet do
  @moduledoc """
  This module transforms binary packets into elixir structures.
  """

  def handle_packet(<<42>>), do: handle_heartbeat()

  def handle_packet(<<43, rest::binary>>), do: handle_get(rest)

  def handle_packet(<<44, rest::binary>>), do: handle_set(rest)

  def handle_packet(<<45, rest::binary>>), do: handle_forget(rest)

  def handle_packet(_packet), do: error(:unexpected_packet)

  defp handle_heartbeat() do
    IO.puts("Received a heartbeat")
    {:ok, :heartbeat}
  end

  defp handle_get(<<length::8, name::binary-size(length)>>) do
    IO.puts("Received a get '#{name}' request")
    {:ok, [:get, name: name]}
  end

  def handle_set(<<length::8, name::binary-size(length), rest::binary>>) do
    handle_set_payload(rest, [:set, name: name])
  end

  defp handle_set_payload(<<length::16, payload::binary-size(length)>>, props) do
    {:ok, props ++ [payload: payload]}
  end

  defp handle_set_payload(_payload, _name), do: error(:unexpected_payload)

  defp handle_forget(<<length::8, name::binary-size(length)>>) do
    {:ok, [:forget, name: name]}
  end

  defp handle_forget(_payload), do: error(:unexpected_payload)

  defp error(name) do
    {:error, name}
  end
end

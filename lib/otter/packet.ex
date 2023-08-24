defmodule Otter.Packet do
  @moduledoc """
  This module transforms binary packets into elixir structures.
  """

  @heartbeat 42
  @get 43
  @set 44
  @forget 45

  @doc """
  Parses a binary packet into a keyword list.
  """
  def handle(<<@heartbeat>>), do: handle_heartbeat()

  def handle(<<@get, rest::binary>>), do: handle_get(rest)

  def handle(<<@set, rest::binary>>), do: handle_set(rest)

  def handle(<<@forget, rest::binary>>), do: handle_forget(rest)

  def handle(_packet), do: error(:unexpected_packet)

  defp handle_heartbeat() do
    IO.puts("Received a heartbeat")
    {:ok, :heartbeat}
  end

  defp handle_get(<<length::8, name::binary-size(length)>>) do
    IO.puts("Received a get '#{name}' request")
    {:ok, [:get, name: name]}
  end

  defp handle_set(<<length::8, name::binary-size(length), rest::binary>>) do
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

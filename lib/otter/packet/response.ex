defmodule Otter.Packet.Response do
  @moduledoc """
  This module transforms elixir structures into binary responses.
  """

  @not_found 0
  @found 1
  @created 2
  @updated 3
  @forgotten 4

  @not_found_response <<@not_found::8>>
  @created_response <<@created::8>>
  @updated_response <<@updated::8>>
  @forgotten_response <<@forgotten::8>>

  def handle(:not_found), do: @not_found_response

  def handle([:found, payload: payload]), do: handle_found(payload)

  def handle(:created), do: @created_response

  def handle(:updated), do: @updated_response

  def handle(:forgotten), do: @forgotten_response

  defp handle_found(payload) do
    size = byte_size(payload)
    <<@found::8, size::16, payload::binary>>
  end
end

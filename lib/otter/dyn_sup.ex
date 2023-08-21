defmodule Otter.DynSup do
  @moduledoc """
  This module is reponsible to dynamically handle multiple connections
  in the same listener by starting `Otter.Sv` childs.
  """
  use DynamicSupervisor

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    options = [
      strategy: :one_for_one,
      max_children: 500,
      period: 3600,
      intensity: 60
    ]

    DynamicSupervisor.init(options)
  end

  @doc """
  Starts a `Otter.Sv` child with the given `listener`.
  """
  def start_child(listener) do
    spec = %{
      id: Otter.Sv,
      start: {Otter.Sv, :start_link, [listener]},
      restart: :temporary,
      shutdown: 500
    }

    child = DynamicSupervisor.start_child(__MODULE__, spec)
    IO.puts("Starting child #{inspect(child)}")
    child
  end
end

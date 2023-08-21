defmodule Otter.Sup do
  use Supervisor

  @tcp_port 8080
  @tcp_opts [:binary, packet: 2, active: true, reuseaddr: true]

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, listener} = :gen_tcp.listen(@tcp_port, @tcp_opts)

    children = [
      %{
        id: Otter.DynSup,
        start: {Otter.DynSup, :start_link, []}
      },
      {Task, init_children(listener)}
    ]

    options = [strategy: :one_for_one]
    Supervisor.init(children, options)
  end

  defp init_children(listener) do
    fn ->
      Enum.to_list(1..10)
      |> Enum.each(fn _ -> Otter.DynSup.start_child(listener) end)
    end
  end
end

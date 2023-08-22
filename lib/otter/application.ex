defmodule Otter.Application do
  use Application

  def start(_type, _args) do
    Otter.Sup.start_link()
  end
end

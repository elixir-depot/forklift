defmodule Forklift.Storage.Memory do
  use Forklift.Storage.Depot, adapter: Depot.Adapter.InMemory

  @impl Forklift.Storage
  def url(_, id) do
    "memory://" <> id
  end
end

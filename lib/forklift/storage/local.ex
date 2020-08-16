defmodule Forklift.Storage.Local do
  use Forklift.Storage.Depot, adapter: Depot.Adapter.Local

  @impl Forklift.Storage
  def url({_, config}, id) do
    "file://" <> full_path(config, id)
  end

  defp full_path(config, path) do
    Depot.RelativePath.join_prefix(config.prefix, path)
  end
end

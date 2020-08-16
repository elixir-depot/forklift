defmodule Forklift.Storage.Depot do
  @moduledoc """
  Derive a `Forklift.Storage` from a `Depot.Adapter`.
  Using this module will implement all callbacks of `Forklift.Storage` besides
  `url/2`, which does need to be implemented manually. Depot doesn't deal with
  filesystems being generaly network accessible, so it doesn't support the
  notion of files having urls.

  See `__using__/1` for examples.
  """

  @doc """
  Derive a `Forklift.Storage` from a `Depot.Adapter`.

  ## Example

      defmodule Forklift.Storage.Local do
        use Forklift.Storage.Depot, adapter: Depot.Adapter.Local

        def url({_, config}, id) do
          "file://" <> full_path(config, id)
        end

        defp full_path(config, path) do
          Depot.RelativePath.join_prefix(config.prefix, path)
        end
      end

  """
  defmacro __using__(opts) do
    adapter = Keyword.fetch!(opts, :adapter)

    quote do
      @behaviour Forklift.Storage
      @adapter unquote(adapter)

      @impl Forklift.Storage
      def new(opts) do
        @adapter.configure(opts)
      end

      @impl Forklift.Storage
      def upload(filesystem, id, liftable, opts) do
        Depot.write(filesystem, id, Forklift.Liftable.to_iodata(liftable), opts)
      end

      @impl Forklift.Storage
      def download(filesystem, id, opts) do
        Depot.read(filesystem, id, opts)
      end

      @impl Forklift.Storage
      def exists?(filesystem, id) do
        case Depot.file_exists(filesystem, id) do
          {:ok, :exists} -> true
          {:ok, :missing} -> false
        end
      end

      @impl Forklift.Storage
      def delete(filesystem, id) do
        Depot.delete(filesystem, id)
      end

      @impl Forklift.Storage
      def delete_prefixed(filesystem, prefix) do
        raise "Decide in :depot how to handle this."
      end

      @impl Forklift.Storage
      def clear(filesystem) do
        raise "Decide in :depot how to handle this."
      end
    end
  end
end

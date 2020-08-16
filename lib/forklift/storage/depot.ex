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

      if @adapter.starts_processes() do
        def child_spec(config) do
          Supervisor.child_spec({@adapter, config}, %{})
        end
      end

      @impl Forklift.Storage
      def new(opts) do
        {@adapter, config} = @adapter.configure(opts)
        {__MODULE__, config}
      end

      @impl Forklift.Storage
      def upload({_storage, config}, id, liftable, opts) do
        Depot.write({@adapter, config}, id, Forklift.Liftable.to_iodata(liftable), opts)
      end

      @impl Forklift.Storage
      def download({_storage, config}, id, opts) do
        Depot.read({@adapter, config}, id, opts)
      end

      @impl Forklift.Storage
      def exists?({_storage, config}, id) do
        case Depot.file_exists({@adapter, config}, id) do
          {:ok, :exists} -> true
          {:ok, :missing} -> false
        end
      end

      @impl Forklift.Storage
      def delete({_storage, config}, id) do
        Depot.delete({@adapter, config}, id)
      end

      @impl Forklift.Storage
      def delete_prefixed({_storage, config}, prefix) do
        Depot.delete_directory({@adapter, config}, prefix, recursive: true)
      end

      @impl Forklift.Storage
      def clear({_storage, config}) do
        Depot.clear({@adapter, config})
      end
    end
  end
end

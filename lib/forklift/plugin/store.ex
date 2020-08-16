defmodule Forklift.Plugin.Store do
  def inject(opts) do
    cache = Keyword.fetch!(opts, :cache)
    store = Keyword.fetch!(opts, :store)

    quote do
      @cache unquote(cache)
      @store unquote(store)

      def store(io, opts \\ []) do
        {:ok, cache} = fetch_storage(@cache)
        {:ok, store} = fetch_storage(@store)

        location = Keyword.get(opts, :location, generate_location(io, opts))

        config = %{
          cache: cache,
          cache_key: @cache,
          store: store,
          store_key: @store
        }

        Forklift.Plugin.Store.store(config, location, io, opts)
      end

      defoverridable store: 2
    end
  end

  def store(config, location, %Forklift.File{} = file, _opts) do
    config.cache_key == file.storage_key
    {cache, _} = config.cache
    {store, _} = config.store

    Forklift.async(fn ->
      # TODO make this Forklift specific (Wrapper around depot)
      Depot.copy_between_filesystem(
        {cache.__depot__(config.cache), file.id},
        {store.__depot__(config.store), location}
      )
    end)

    {:ok,
     %Forklift.File{
       id: location,
       storage_key: config.store_key,
       metadata: file.metadata
     }}
  end

  def store(config, location, file, opts) do
    {:ok, file} = Forklift.upload(config.cache, config.cache_key, location, file, opts)
    store(config, location, file, opts)
  end
end

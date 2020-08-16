defmodule Forklift.Storage do
  @type t :: {module(), term}
  @type liftable :: Forklift.Liftable.t()

  @callback starts_processes() :: boolean

  @callback new(opts :: Keyword.t()) :: storage :: t

  @callback upload(
              storage :: t,
              io :: Forklift.IO.t(),
              id :: liftable,
              opts :: Keyword.t()
            ) :: :ok | {:error, any}

  @callback download(storage :: t, id :: String.t(), opts :: Keyword.t()) ::
              {:ok, binary} | {:error, any}

  @callback exists?(storage :: t, id :: String.t()) :: boolean

  @callback url(storage :: t, id :: String.t()) :: String.t()

  @callback delete(storage :: t, id :: String.t()) :: :ok | {:error, any}

  @callback delete_prefixed(storage :: t, prefix :: String.t()) :: :ok | {:error, any}

  @callback clear(storage :: t) :: :ok | {:error, any}

  def starts_processes({module, _} = storage) do
    module.starts_processes()
  end

  def new({module, opts}) do
    module.new(opts)
  end

  def new(module) do
    module.new([])
  end

  def upload({module, _} = storage, id, io, opts \\ []) do
    module.upload(storage, id, io, opts)
  end

  def download({module, _} = storage, id, opts \\ []) do
    module.download(storage, id, opts)
  end

  def exists?({module, _} = storage, id) do
    module.exists?(storage, id)
  end

  def url({module, _} = storage, id) do
    module.url(storage, id)
  end

  def delete({module, _} = storage, id) do
    module.delete(storage, id)
  end

  def delete_prefixed({module, _} = storage, prefix) do
    module.delete_prefixed(storage, prefix)
  end

  def clear({module, _} = storage) do
    module.clear(storage)
  end
end

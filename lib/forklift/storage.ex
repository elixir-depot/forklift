defmodule Forklift.Storage do
  @type t :: struct

  @callback new(opts :: Keyword.t()) :: storage :: t

  @callback upload(
              storage :: t,
              io :: Forklift.IO.t(),
              id :: String.t(),
              opts :: Keyword.t()
            ) :: :ok | {:error, any}

  @callback download(storage :: t, id :: String.t(), opts :: Keyword.t()) ::
              {:ok, binary} | {:error, any}

  @callback exists?(storage :: t, id :: String.t()) :: boolean

  @callback url(storage :: t, id :: String.t()) :: String.t()

  @callback delete(storage :: t, id :: String.t()) :: :ok | {:error, any}

  @callback delete_prefixed(storage :: t, prefix :: String.t()) :: :ok | {:error, any}

  @callback clear(storage :: t) :: :ok | {:error, any}

  def upload(%module{} = storage, id, io, opts \\ []) do
    module.upload(storage, id, io, opts)
  end

  def download(%module{} = storage, id, opts \\ []) do
    module.download(storage, id, opts)
  end

  def exists?(%module{} = storage, id) do
    module.exists?(storage, id)
  end

  def url(%module{} = storage, id) do
    module.url(storage, id)
  end

  def delete(%module{} = storage, id) do
    module.delete(storage, id)
  end

  def delete_prefixed(%module{} = storage, prefix) do
    module.delete_prefixed(storage, prefix)
  end

  def clear(%module{} = storage) do
    module.clear(storage)
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour Forklift.Storage

      alias Forklift.Storage
    end
  end
end

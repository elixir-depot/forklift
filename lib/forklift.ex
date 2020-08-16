defmodule Forklift do
  @moduledoc """
  Documentation for `Forklift`.
  """

  @type file :: Forklift.UploadedFile.t()
  @type storage :: Forklift.Storage.t()

  @callback storages(opts :: keyword) :: %{optional(atom) => Forklift.Storage.t()}

  defmacro __using__(_opts) do
    quote do
      import Forklift.Plugin, only: [plugin: 1, plugin: 2]
      @behaviour Forklift

      def child_spec(init_arg) do
        init_arg
        |> Forklift.Supervisor.child_spec()
        |> Supervisor.child_spec(%{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [init_arg]}
        })
      end

      def start_link(init_arg) do
        Forklift.Supervisor.start_link(__MODULE__, init_arg)
      end

      defp fetch_storage(key) do
        {__MODULE__, :storages}
        |> :persistent_term.get(%{})
        |> Map.fetch(key)
      end

      def upload(storage_key, io, opts \\ []) do
        {:ok, storage} = fetch_storage(storage_key)
        location = Keyword.get(opts, :location, generate_location(io, opts))
        Forklift.upload(storage, storage_key, location, io, opts)
      end

      def generate_location(io, opts) do
        Forklift.basic_location(io, opts)
      end

      def download(storage_key, id, opts \\ []) do
        {:ok, storage} = fetch_storage(storage_key)
        Forklift.download(storage, id, opts)
      end

      defoverridable upload: 2,
                     upload: 3,
                     generate_location: 2,
                     download: 2,
                     download: 3
    end
  end

  def upload(storage, storage_key, location, io, opts) do
    metadata = get_metadata(io, opts)
    opts = [location: location, metadata: metadata] ++ opts

    case Forklift.Storage.upload(storage, location, io, opts) do
      :ok ->
        {:ok,
         %Forklift.File{
           id: location,
           storage_key: storage_key,
           metadata: metadata
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_metadata(%Forklift.File{metadata: metadata}, opts) do
    Map.merge(metadata, Keyword.get(opts, :metadata, %{}))
  end

  defp get_metadata(%Plug.Upload{} = file, opts) do
    metadata = %{
      "filename" => file.filename,
      "size" => File.stat!(file.path).size,
      "mime_type" => file.content_type
    }

    Map.merge(metadata, Keyword.get(opts, :metadata, %{}))
  end

  def basic_location(input, opts) do
    metadata = Keyword.get(opts, :metadata, %{})

    extension =
      case Forklift.Metadata.fetch_extension(metadata) do
        {:ok, ext} -> ext
        _ -> Forklift.Liftable.extension(input)
      end

    basename = generate_id()
    basename <> extension
  end

  defp generate_id() do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
  end

  def download(storage, id, opts) do
    Forklift.Storage.download(storage, id, opts)
  end

  @async_driver Application.compile_env(:forklift, :async_driver, Forklift.Async.Task)

  def async(fun) when is_function(fun, 0) do
    @async_driver.run(fun)
  end
end

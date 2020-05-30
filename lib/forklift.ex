defmodule Forklift do
  @moduledoc """
  Documentation for `Forklift`.
  """

  @type file :: Forklift.UploadedFile.t()
  @type storage :: Forklift.Storage.t()

  defmacro __using__(opts) do
    quote do
      import Forklift

      @storages Map.new(unquote(Keyword.fetch!(opts, :storages)))

      defstruct [:storage_key, :storage]

      def new(storage_key) do
        storage =
          @storages
          |> Map.fetch!(storage_key)
          |> Forklift.create_storage()

        %__MODULE__{storage_key: storage_key, storage: storage}
      end

      def upload(uploader, io, opts \\ []) do
        location = Keyword.get(opts, :location, generate_location(io, opts))
        Forklift.upload(uploader, location, io, opts)
      end

      def generate_location(io, opts) do
        Forklift.basic_location(io, opts)
      end

      def download(uploader, id, opts \\ []) do
        Forklift.download(uploader, id, opts)
      end

      defoverridable upload: 2,
                     upload: 3,
                     generate_location: 2,
                     download: 2,
                     download: 3
    end
  end

  def create_storage({module, opts}) do
    module.new(opts)
  end

  def create_storage(module) when is_atom(module) do
    create_storage({module, []})
  end

  def upload(uploader, location, io, opts) do
    metadata = get_metadata(io, opts)
    opts = [location: location, metadata: metadata] ++ opts

    case Forklift.Storage.upload(uploader.storage, location, io, opts) do
      :ok ->
        {:ok,
         %Forklift.File{
           id: location,
           storage_key: uploader.storage_key,
           storage: uploader.storage,
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

  def basic_location(io, opts) do
    # should opts have precedence?
    extension =
      case Forklift.IO.extension(io) do
        "" ->
          case Keyword.get(opts, :metadata) do
            %{"filename" => filename} ->
              filename
              |> Path.extname()
              |> String.downcase()

            _ ->
              ""
          end

        extension ->
          extension
      end

    basename = generate_id()
    basename <> extension
  end

  defp generate_id() do
    :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
  end

  def download(uploader, id, opts) do
    Forklift.Storage.download(uploader.storage, id, opts)
  end

  alias Forklift.Attachment

  def attachment_from_upload(file, opts) do
    filesystem = opts |> Keyword.fetch!(:cache) |> filesystem()
    contents = File.read!(file.path)

    case Depot.write(filesystem, file.filename, contents) do
      :ok -> %Attachment{id: file.filename}
      _ -> %Attachment{id: nil}
    end
  end

  def attachment_from_path(path, opts) do
    filesystem = opts |> Keyword.fetch!(:cache) |> filesystem()

    case Depot.file_exists(filesystem, path) do
      {:ok, :exists} -> %Attachment{id: path}
      _ -> %Attachment{id: nil}
    end
  end

  defp filesystem(filesystem) when is_tuple(filesystem) do
    filesystem
  end

  defp filesystem(filesystem) when is_atom(filesystem) do
    filesystem.__filesystem__()
  end
end

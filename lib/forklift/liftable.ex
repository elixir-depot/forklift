defprotocol Forklift.Liftable do
  @type t :: term()

  @spec to_iodata(t) :: iodata() | false
  def to_iodata(data)

  @spec extension(t) :: String.t()
  def extension(data)

  @spec metadata(t) :: %{String.t() => term}
  def metadata(data)
end

defimpl Forklift.Liftable, for: Tuple do
  def to_iodata({:binary, binary}), do: binary
  def to_iodata({:file, path}), do: File.read!(path)

  def extension({:binary, binary}), do: ""
  def extension({:file, path}), do: Path.extname(path)

  def metadata({:binary, binary}) do
    %{
      "size" => byte_size(binary)
    }
  end

  def metadata({:file, path}) do
    %{
      "filename" => Path.basename(path),
      "size" => File.stat!(path).size,
      "mime_type" => MIME.from_path(path)
    }
  end
end

defimpl Forklift.Liftable, for: Forklift.File do
  def to_iodata(_), do: false

  def extension(%Forklift.File{id: id}), do: Path.extname(id)

  def metadata(%Forklift.File{metadata: metadata}), do: metadata
end

if Code.ensure_loaded?(Plug.Upload) do
  defimpl Forklift.Liftable, for: Plug.Upload do
    def to_iodata(%Plug.Upload{path: path}), do: File.read!(path)

    def extension(%Plug.Upload{filename: filename}), do: Path.extname(filename)

    def metadata(%Plug.Upload{} = file) do
      %{
        "filename" => file.filename,
        "size" => File.stat!(file.path).size,
        "mime_type" => file.content_type
      }
    end
  end
end

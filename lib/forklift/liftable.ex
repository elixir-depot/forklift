defprotocol Forklift.Liftable do
  @type t :: term()

  @spec to_iodata(t) :: iodata() | false
  def to_iodata(data)

  @spec extension(t) :: String.t()
  def extension(data)
end

defimpl Forklift.Liftable, for: Tuple do
  def to_iodata({:binary, binary}), do: binary
  def to_iodata({:file, path}), do: File.read!(path)

  def extension({:binary, binary}), do: ""
  def extension({:file, path}), do: Path.extname(path)
end

defimpl Forklift.Liftable, for: Forklift.File do
  def to_iodata(_), do: false

  def extension(%Forklift.File{id: id}), do: Path.extname(id)
end

if Code.ensure_loaded?(Plug.Upload) do
  defimpl Forklift.Liftable, for: Plug.Upload do
    def to_iodata(%Plug.Upload{path: path}), do: File.read!(path)

    def extension(%Plug.Upload{filename: filename}), do: Path.extname(filename)
end
end

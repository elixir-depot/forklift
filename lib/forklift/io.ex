defprotocol Forklift.IO do
  def extension(io)
end

defimpl Forklift.IO, for: Forklift.File do
  def extension(%{metadata: %{"filename" => filename}}) do
    Path.extname(filename)
  end
end

if Code.ensure_loaded?(Plug.Upload) do
  defimpl Forklift.IO, for: Plug.Upload do
    def extension(%{filename: filename}) do
      Path.extname(filename)
    end
  end
end

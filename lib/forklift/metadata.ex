defmodule Forklift.Metadata do
  def fetch_filename(metadata) do
    Map.fetch(metadata, "filename")
  end

  def fetch_extension(metadata) do
    with {:ok, filename} <- fetch_filename(metadata) do
      Path.extname(filename)
    end
  end
end

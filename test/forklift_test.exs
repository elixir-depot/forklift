defmodule ForkliftTest do
  use ExUnit.Case
  doctest Forklift

  defmodule MemoryUploader do
    use Forklift,
      storages: [
        memory: Forklift.Storage.Memory
      ]

    plugin Forklift.Telemetry
  end

  def create_plug_upload do
    path = __ENV__.file

    %Plug.Upload{
      path: path,
      filename: Path.basename(path),
      content_type: "text/plain"
    }
  end

  setup do
    [uploader: MemoryUploader.new(:memory), io: create_plug_upload()]
  end

  test "upload", %{uploader: uploader, io: io} do
    assert {:ok, %Forklift.File{} = file} = MemoryUploader.upload(uploader, io)
    assert file.id
    assert file.storage_key == :memory
    assert file.metadata
  end

  test "download", %{uploader: uploader, io: io} do
    {:ok, file} = MemoryUploader.upload(uploader, io)

    assert {:ok, contents} = MemoryUploader.download(uploader, file.id)
    assert contents == File.read!(io.path)
  end

  test "copy", %{uploader: source, io: io} do
    {:ok, original} = MemoryUploader.upload(source, io)

    destination = MemoryUploader.new(:memory)
    assert {:ok, copy} = MemoryUploader.upload(destination, original)
    assert original.id != copy.id
    assert original.metadata == copy.metadata
  end
end

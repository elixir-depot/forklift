defmodule ForkliftTest do
  use ExUnit.Case
  import Forklift.TestHelpers
  doctest Forklift

  defmodule MemoryUploader do
    use Forklift,
      storages: [
        memory: {Forklift.Storage.Memory, name: ForkliftTest.Uploader}
      ]
  end

  setup do
    uploader = MemoryUploader.new(:memory)
    start_supervised!(uploader.storage)
    [uploader: uploader, io: create_plug_upload()]
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

  @tag :skip
  test "copy", %{uploader: source, io: io} do
    {:ok, original} = MemoryUploader.upload(source, io)

    destination = MemoryUploader.new(:memory)
    assert {:ok, copy} = MemoryUploader.upload(destination, original)
    assert original.id != copy.id
    assert original.metadata == copy.metadata
  end
end

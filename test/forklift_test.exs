defmodule ForkliftTest do
  use ExUnit.Case
  import Forklift.TestHelpers
  doctest Forklift

  defmodule MemoryUploader do
    use Forklift

    def storages do
      %{
        memory: {Forklift.Storage.Memory, name: ForkliftTest.Uploader},
        store: {Forklift.Storage.Memory, name: ForkliftTest.Uploader2}
      }
    end
  end

  setup do
    start_supervised!(MemoryUploader)
    [io: create_plug_upload()]
  end

  test "upload", %{io: io} do
    assert {:ok, %Forklift.File{} = file} = MemoryUploader.upload(:memory, io)
    assert file.id
    assert file.storage_key == :memory
    assert file.metadata
  end

  test "download", %{io: io} do
    {:ok, file} = MemoryUploader.upload(:memory, io)

    assert {:ok, contents} = MemoryUploader.download(:memory, file.id)
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

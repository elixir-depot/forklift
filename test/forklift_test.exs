defmodule ForkliftTest do
  use ExUnit.Case
  import Forklift.TestHelpers
  doctest Forklift

  defmodule MemoryUploader do
    use Forklift

    plugin(Forklift.Plugin.Store, cache: :memory, store: :store)

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

  test "copy", %{io: io} do
    {:ok, original} = MemoryUploader.upload(:memory, io)

    assert {:ok, copy} = MemoryUploader.store(original)
    assert original.id != copy.id
    assert original.metadata == copy.metadata

    assert {:ok, contents} = MemoryUploader.download(:store, copy.id)
    assert contents == File.read!(io.path)
  end
end

defmodule Forklift.Storage.MemoryTest do
  use ExUnit.Case

  alias Forklift.Storage
  alias Forklift.Storage.Memory

  setup_all do
    [io: ForkliftTest.create_plug_upload()]
  end

  setup do
    [storage: Memory.new()]
  end

  test "upload", %{storage: storage, io: io} do
    assert :ok = Storage.upload(storage, "foo.txt", io)
  end

  test "download", %{storage: storage, io: io} do
    Storage.upload(storage, "foo.txt", io)
    assert {:ok, _contents} = Storage.download(storage, "foo.txt")
  end

  test "exists?", %{storage: storage, io: io} do
    refute Storage.exists?(storage, "foo.txt")

    Storage.upload(storage, "foo.txt", io)
    assert Storage.exists?(storage, "foo.txt")
  end

  test "url", %{storage: storage, io: io} do
    Storage.upload(storage, "foo.txt", io)
    assert "memory://foo.txt" == Storage.url(storage, "foo.txt")
  end

  test "delete", %{storage: storage, io: io} do
    Storage.upload(storage, "foo.txt", io)
    assert :ok = Storage.delete(storage, "foo.txt")
    refute Storage.exists?(storage, "foo.txt")
  end

  test "delete_prefixed", %{storage: storage, io: io} do
    Storage.upload(storage, "foo.txt", io)
    Storage.upload(storage, "foo.png", io)

    assert :ok = Storage.delete_prefixed(storage, "foo")
    refute Storage.exists?(storage, "foo.txt")
    refute Storage.exists?(storage, "foo.png")
  end

  test "clear", %{storage: storage, io: io} do
    Storage.upload(storage, "foo.txt", io)
    Storage.upload(storage, "foo.png", io)

    assert :ok = Storage.clear(storage)
    refute Storage.exists?(storage, "foo.txt")
    refute Storage.exists?(storage, "foo.png")
  end
end

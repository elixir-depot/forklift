defmodule Forklift.Storage.Memory do
  use GenServer
  use Forklift.Storage

  defstruct [:pid]

  @impl Storage
  def new(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
    %__MODULE__{pid: pid}
  end

  @impl Storage
  def upload(%{pid: pid}, id, %Plug.Upload{path: path}, _opts) do
    contents = File.read!(path)
    GenServer.call(pid, {:put, id, contents})
  end

  def upload(%{pid: pid}, to, %Forklift.File{id: from, storage: storage}, opts) do
    case download(storage, from, opts) do
      {:ok, contents} -> GenServer.call(pid, {:put, to, contents})
      {:error, reason} -> {:error, reason}
    end
  end

  @impl Storage
  def download(%{pid: pid}, id, _opts) do
    case GenServer.call(pid, {:fetch, id}) do
      {:ok, contents} -> {:ok, contents}
      :error -> {:error, Forklift.FileNotFoundError}
    end
  end

  @impl Storage
  def exists?(%{pid: pid}, id) do
    GenServer.call(pid, {:exists?, id})
  end

  @impl Storage
  def url(_storage, id) do
    "memory://" <> id
  end

  @impl Storage
  def delete(%{pid: pid}, id) do
    GenServer.call(pid, {:delete, id})
  end

  @impl Storage
  def delete_prefixed(%{pid: pid}, prefix) do
    GenServer.call(pid, {:delete_prefixed, prefix})
  end

  @impl Storage
  def clear(%{pid: pid}) do
    GenServer.call(pid, :clear)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:put, id, contents}, _from, state) do
    {:reply, :ok, Map.put(state, id, contents)}
  end

  def handle_call({:fetch, id}, _from, state) do
    {:reply, Map.fetch(state, id), state}
  end

  def handle_call({:exists?, id}, _from, state) do
    {:reply, Map.has_key?(state, id), state}
  end

  def handle_call({:delete, id}, _from, state) do
    {:reply, :ok, Map.delete(state, id)}
  end

  def handle_call({:delete_prefixed, prefix}, _from, state) do
    state =
      state
      |> Enum.reject(fn {id, _contents} -> String.starts_with?(id, prefix) end)
      |> Map.new()

    {:reply, :ok, state}
  end

  def handle_call(:clear, _from, _state) do
    {:reply, :ok, %{}}
  end
end

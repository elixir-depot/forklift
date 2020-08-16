defmodule Forklift.Supervisor do
  use Supervisor

  def start_link(module, init_arg) do
    Supervisor.start_link(__MODULE__, {module, init_arg}, name: module)
  end

  @impl true
  def init({module, init_arg}) do
    storages =
      Map.new(module.storages(), fn {key, setup} ->
        {key, Forklift.Storage.new(setup)}
      end)

    # Maybe replace with a process + ets
    :persistent_term.put({module, :storages}, storages)

    children =
      for {key, storage} <- storages,
          Forklift.Storage.starts_processes(storage),
          do: Supervisor.child_spec(storage, id: storage)

    if children == [] do
      :ignore
    else
      Supervisor.init(children, strategy: :one_for_one)
    end
  end
end

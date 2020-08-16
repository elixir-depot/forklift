defmodule Forklift.Async do
  @callback run((() -> term)) :: :ok
end

defmodule Forklift.Async.Task do
  @behaviour Forklift.Async

  def run(fun) when is_function(fun, 0) do
    Task.start(fun)
    :ok
  end
end

defmodule Forklift.Async.Sync do
  @behaviour Forklift.Async

  def run(fun) when is_function(fun, 0) do
    fun.()
    :ok
  end
end

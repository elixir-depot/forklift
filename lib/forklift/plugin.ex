defmodule Forklift.Plugin do
  def plugin(module, opts \\ []) do
    module.inject(opts)
  end
end

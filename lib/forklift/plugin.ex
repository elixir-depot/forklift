defmodule Forklift.Plugin do
  defmacro plugin(module, opts \\ []) do
    module = Macro.expand(module, __CALLER__)
    module.inject(opts)
  end
end

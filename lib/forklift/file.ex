defmodule Forklift.File do
  defstruct [:id, :storage_key, :storage, metadata: %{}]

  @type t :: %__MODULE__{
          id: String.t(),
          storage_key: atom,
          storage: struct,
          metadata: map
        }
end

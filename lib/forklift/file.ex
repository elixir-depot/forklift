defmodule Forklift.File do
  defstruct [:id, :storage_key, metadata: %{}]

  @type t :: %__MODULE__{
          id: String.t(),
          storage_key: atom,
          metadata: map
        }

  def to_json(%__MODULE__{} = data) do
    data
    |> Map.from_struct()
    |> Jason.encode!()
  end

  def from_json(%{} = data) do
    struct!(__MODULE__, %{
      id: data["id"],
      storage_key: String.to_existing_atom(data["storage_key"]),
      metadata: data["metadata"]
    })
  end

  if Code.ensure_loaded?(Phoenix.HTML.Safe) do
    defimpl Phoenix.HTML.Safe do
      def to_iodata(data) do
        {:safe, safe} =
          data
          |> Forklift.File.to_json()
          |> Phoenix.HTML.html_escape()

        safe
      end
    end
  end
end

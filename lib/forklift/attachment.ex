defmodule Forklift.Attachment do
  defstruct id: nil

  def to_json(%__MODULE__{} = data) do
    data
    |> Map.from_struct()
    |> Jason.encode!()
  end

  def from_json(%{} = data) do
    struct!(__MODULE__, %{
      id: data["id"]
    })
  end

  if Code.ensure_loaded?(Phoenix.HTML.Safe) do
    defimpl Phoenix.HTML.Safe do
      def to_iodata(data) do
        {:safe, safe} =
          Forklift.Attachment.to_json(data)
          |> Phoenix.HTML.html_escape()

        safe
      end
    end
  end
end

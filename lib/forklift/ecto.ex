defmodule Forklift.Ecto do
  # defmacro generate(opts) do
  #   quote do
  #     use Ecto.Type
  #     alias Forklift.Attachment

  #     defdelegate validate_cache_filled(changeset, field, opts \\ []), to: Forklift.Ecto
  #     def embed_as(_), do: :dump
  #     def type, do: :map
  #     def cast(value), do: Forklift.Ecto.cast(value, unquote(opts))
  #     def dump(value), do: Forklift.Ecto.dump(value)
  #     def load(value), do: Forklift.Ecto.load(value)
  #   end
  # end

  # alias Forklift.Attachment

  # def validate_cache_filled(changeset, field, opts \\ []) do
  #   msg = Keyword.get(opts, :message, "didn't upload properly")

  #   Ecto.Changeset.validate_change(changeset, field, fn ^field, attachment ->
  #     case attachment.id do
  #       nil -> [{field, msg}]
  #       _ -> []
  #     end
  #   end)
  # end

  # def cast(%Attachment{} = attachment, _), do: {:ok, attachment}

  # if Code.ensure_loaded?(Plug.Upload) do
  #   def cast(%Plug.Upload{} = file, opts) do
  #     attachment = Forklift.attachment_from_upload(file, opts)
  #     {:ok, attachment}
  #   end
  # end

  # def cast(input, opts) when is_binary(input) do
  #   attachment =
  #     case Jason.decode(input) do
  #       {:ok, json} -> Attachment.from_json(json)
  #       _ -> Forklift.attachment_from_path(input, opts)
  #     end

  #   {:ok, attachment}
  # end

  # def cast(_, _), do: :error

  # def load(data) when is_map(data) do
  #   data =
  #     for {key, val} <- data do
  #       {String.to_existing_atom(key), val}
  #     end

  #   {:ok, struct!(Attachment, data)}
  # end

  # def dump(%Attachment{} = attachment), do: {:ok, Map.from_struct(attachment)}
  # def dump(_), do: :error
end

defmodule Forklift do
  @moduledoc """
  Documentation for `Forklift`.
  """

  defmacro __using__(opts) do
    quote do
      import Forklift

      @cache unquote(Keyword.fetch!(opts, :cache))
      @store unquote(Keyword.fetch!(opts, :store))
    end
  end

  defmacro plugin(mod, opts \\ []) do
    quote do
      require unquote(mod)
      unquote(mod).generate(Keyword.merge([store: @store, cache: @cache], unquote(opts)))
    end
  end

  alias Forklift.Attachment

  def attachment_from_upload(file, opts) do
    filesystem = opts |> Keyword.fetch!(:cache) |> filesystem()
    contents = File.read!(file.path)

    case Depot.write(filesystem, file.filename, contents) do
      :ok -> %Attachment{id: file.filename}
      _ -> %Attachment{id: nil}
    end
  end

  def attachment_from_path(path, opts) do
    filesystem = opts |> Keyword.fetch!(:cache) |> filesystem()

    case Depot.file_exists(filesystem, path) do
      {:ok, :exists} -> %Attachment{id: path}
      _ -> %Attachment{id: nil}
    end
  end

  defp filesystem(filesystem) when is_tuple(filesystem) do
    filesystem
  end

  defp filesystem(filesystem) when is_atom(filesystem) do
    filesystem.__filesystem__()
  end
end

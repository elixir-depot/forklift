ExUnit.start(exclude: [:skip])

defmodule Forklift.TestHelpers do
  def create_plug_upload do
    path = __ENV__.file

    %Plug.Upload{
      path: path,
      filename: Path.basename(path),
      content_type: "text/plain"
    }
  end
end

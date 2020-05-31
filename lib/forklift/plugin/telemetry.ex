defmodule Forklift.Telemetry do
  def inject(_opts) do
    quote do
      require Logger

      defp now, do: System.monotonic_time()

      def upload(uploader, io, opts \\ []) do
        start = now()
        :telemetry.execute([:forklift, :upload, :start], %{system_time: start})
        result = super(uploader, io, opts)
        :telemetry.execute([:forklift, :upload, :stop], %{duration: now() - start})
        result
      end

      def download(uploader, id, opts \\ []) do
        start = now()
        :telemetry.execute([:forklift, :download, :start], %{system_time: start})
        result = super(uploader, id, opts)
        :telemetry.execute([:forklift, :download, :stop], %{duration: now() - start})
        result
      end

      defoverridable upload: 2, upload: 3, download: 2, download: 3
    end
  end
end

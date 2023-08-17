defmodule Patchwork.Patch.PatchError do
  defexception [:message]

  @impl true
  def exception(detail) do
    %__MODULE__{message: "Patch does not apply: #{inspect(detail)}"}
  end
end

defprotocol Patchwork.Patch do
  @doc """
  This is the type of the patch struct returned by diff.
  E.g. `%Patchwork.Patch.Map{}`
  """
  @type patch_type :: any()

  @fallback_to_any true

  alias Patchwork.Patch.PatchError

  @spec diff(t, t) :: patch_type
  def diff(value_a, value_b)

  @spec apply(t, patch_type) :: {:ok, t() | {:error, PatchError.t()}}
  def apply(value, patch)
end

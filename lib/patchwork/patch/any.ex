defimpl Patchwork.Patch, for: Any do
  alias Patchwork.Patch

  @doc """
  Generic implementation of Patch.diff/2 protocol for any struct.
  """
  @impl true
  def diff(%type{} = struct_a, %type{} = struct_b)
      when is_struct(struct_a) and is_struct(struct_b) do
    map_a = Map.from_struct(struct_a)
    map_b = Map.from_struct(struct_b)

    Patch.diff(map_a, map_b)
  end

  @doc """
  Generic implementation of Patch.apply/2 protocol for any struct.
  """
  @impl true
  def apply(%type{} = struct, %Patch.Map{} = patch) when is_struct(struct) do
    with {:ok, updated_map} <-
           struct
           |> Map.from_struct()
           |> Patch.apply(patch) do
      {:ok, struct(type, updated_map)}
    end
  end
end

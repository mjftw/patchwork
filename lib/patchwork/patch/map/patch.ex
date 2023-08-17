defimpl Patchwork.Patch, for: Map do
  @type t :: %__MODULE__{
          added: %{any() => any()},
          modified: %{any() => any()},
          removed: [atom()]
        }

  defstruct added: %{}, modified: %{}, removed: []

  alias Patchwork.Patch.PatchError

  @doc """
  Computes the difference of two Maps.

  ## Examples

      iex> Patchwork.Patch.diff(%{a: 1, b: 2, c: 3}, %{b: 2, c: 4, d: 5})
      %Patchwork.Patch.Map{added: %{d: 5}, modified: %{c: 4}, removed: [:a]}

      iex> Patchwork.Patch.diff(%{a: 1, b: 2, c: 3}, %{a: 1, b: 2, c: 3})
      %Patchwork.Patch.Map{added: %{}, modified: %{}, removed: []}

      iex> Patchwork.Patch.diff(%{}, %{a: 1, b: 2, c: 3})
      %Patchwork.Patch.Map{added: %{a: 1, b: 2, c: 3}, modified: %{}, removed: []}

      iex> Patchwork.Patch.diff(%{"a" => "1", "b" => 2, "c" =>  3}, %{"a" => 1, "b" => "2", "c" => 3.0})
      %Patchwork.Patch.Map{
        added: %{},
        modified: %{"a" => 1, "b" => "2", "c" => 3.0},
        removed: []
      }
  """
  @impl true
  @spec diff(map(), map()) :: __MODULE__.t()
  def diff(from, to) do
    Enum.reduce(
      Map.merge(from, to),
      %__MODULE__{added: %{}, modified: %{}, removed: []},
      fn {k, v}, %__MODULE__{added: added, modified: modified, removed: removed} ->
        {added, modified} =
          case Map.fetch(from, k) do
            {:ok, value} when value === v -> {added, modified}
            {:ok, _} -> {added, Map.put(modified, k, v)}
            :error -> {Map.put(added, k, v), modified}
          end

        removed =
          case Map.has_key?(to, k) do
            true -> removed
            false -> [k | removed]
          end

        %__MODULE__{
          added: added,
          modified: modified,
          removed: removed
        }
      end
    )
  end

  @impl true
  def apply(from, %__MODULE__{
        added: added,
        modified: modified,
        removed: removed
      }) do
    add_result = validate_added(from, added)
    modify_result = validate_modified(from, modified)
    remove_result = validate_removed(from, removed)

    errors =
      Enum.reduce(
        [add_result, modify_result, remove_result],
        [],
        fn
          {:error, error}, errors -> [error | errors]
          :ok, errors -> errors
        end
      )

    case Enum.empty?(errors) do
      true ->
        {:ok,
         from
         |> Map.merge(modified)
         |> Map.merge(added)
         |> Map.drop(removed)}

      false ->
        {:error, PatchError.exception(errors)}
    end
  end

  defp validate_added(from, added) do
    from_keys = MapSet.new(from, fn {k, _v} -> k end)
    added_keys = MapSet.new(added, fn {k, _v} -> k end)
    common_keys = MapSet.intersection(from_keys, added_keys) |> Enum.to_list()

    case common_keys do
      [] -> :ok
      _ -> {:error, "Attempted to add key(s) that are already present: #{inspect(common_keys)}"}
    end
  end

  defp validate_modified(from, modified) do
    errors =
      Enum.reduce(modified, [], fn {k, v}, errors ->
        case Map.fetch(from, k) do
          {:ok, from_v} when from_v === v ->
            [{:value_unchanged, k} | errors]

          :error ->
            [{:key_missing, k} | errors]

          {:ok, _} ->
            errors
        end
      end)
      |> Enum.group_by(fn {error_type, _k} -> error_type end, fn {_error_type, k} -> k end)
      |> Enum.map(fn
        {:value_unchanged, keys} ->
          "Attempted to update key(s) with unchanged value: #{inspect(keys)}"

        {:key_missing, keys} ->
          "Attempted to update key(s) that were not present: #{inspect(keys)}"
      end)

    case Enum.empty?(errors) do
      true -> :ok
      false -> {:error, errors}
    end
  end

  defp validate_removed(from, removed) do
    missing_keys = Enum.filter(removed, &(!Map.has_key?(from, &1)))

    case missing_keys do
      [] -> :ok
      _ -> {:error, "Attempted to remove keys that are not present: #{inspect(missing_keys)}"}
    end
  end
end

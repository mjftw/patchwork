defmodule Patchwork.Patch.Map.PatchTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Patchwork.Patch.Map, as: MapPatch
  # doctest Patchwork.Patch.Map

  test "applying a diff always results in the correct value" do
    check all(
            map1 <- map_generator(),
            map2 <- map_generator()
          ) do
      patch = Patchwork.Patch.diff(map1, map2)
      assert {:ok, map2} == Patchwork.Patch.apply(map1, patch)
    end
  end

  describe "apply/2" do
    test "should error if adding a keys that already exist" do
      assert {:error,
              %Patchwork.Patch.PatchError{
                message:
                  "Patch does not apply: [\"Attempted to add key(s) that are already present: [:b, :c]\"]"
              }} ==
               Patchwork.Patch.apply(%{a: 1, b: 2, c: 3}, %MapPatch{added: %{b: 3, c: 4, d: 5}})
    end

    test "should error if modifying keys that do not exist" do
      assert {:error,
              %Patchwork.Patch.PatchError{
                message:
                  "Patch does not apply: [[\"Attempted to update key(s) that were not present: [:e, :d]\"]]"
              }} ==
               Patchwork.Patch.apply(%{a: 1, b: 2, c: 3}, %MapPatch{
                 modified: %{b: 3, c: 4, d: 5, e: 6}
               })
    end

    test "should error if modifying keys without changing values" do
      assert {:error,
              %Patchwork.Patch.PatchError{
                message:
                  "Patch does not apply: [[\"Attempted to update key(s) with unchanged value: [:b, :a]\"]]"
              }} ==
               Patchwork.Patch.apply(%{a: 1, b: 2, c: 3}, %MapPatch{
                 modified: %{a: 1, b: 2, c: 5}
               })
    end

    test "should error if removing keys that do not exist" do
      assert {:error,
              %Patchwork.Patch.PatchError{
                message:
                  "Patch does not apply: [\"Attempted to remove keys that are not present: [:d, :e]\"]"
              }} ==
               Patchwork.Patch.apply(%{a: 1, b: 2, c: 3}, %MapPatch{
                 removed: [:b, :c, :d, :e]
               })
    end

    test "should combine all detected errors" do
      {:error,
       %Patchwork.Patch.PatchError{
         message: message
       }} =
        Patchwork.Patch.apply(%{a: 1, b: 2, c: 3, d: 4}, %MapPatch{
          added: %{a: 3},
          modified: %{b: 2, c: 4, e: 5},
          removed: [:d, :f]
        })

      assert message =~ "Patch does not apply:"
      assert message =~ "Attempted to add key(s) that are already present: [:a]"
      assert message =~ "Attempted to update key(s) that were not present: [:e]"
      assert message =~ "Attempted to update key(s) with unchanged value: [:b]"
      assert message =~ "Attempted to remove keys that are not present: [:f]"
    end
  end

  defp map_generator do
    gen all(
          map <-
            StreamData.optional_map(%{
              a: StreamData.integer(),
              b: StreamData.binary(),
              c: StreamData.boolean(),
              d: StreamData.constant(0)
            })
        ) do
      map
    end
  end
end

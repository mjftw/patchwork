defmodule Patchwork.Patch.AnyTest do
  use ExUnit.Case
  use ExUnitProperties
  alias Patchwork.Patch

  defmodule Patchwork.Patch.AnyTest.Cat do
    defstruct [:name, :cuteness]
  end

  defmodule Patchwork.Patch.AnyTest.Dog do
    defstruct [:name, :breed]
  end

  alias Patchwork.Patch.AnyTest.{Cat, Dog}

  test "should be able to diff and patch arbitrary struct" do
    check all(
            cat1 <- cat_generator(),
            cat2 <- cat_generator()
          ) do
      patch = Patch.diff(cat1, cat2)

      {:ok, patched_cat} = Patch.apply(cat1, patch)
      %type{} = patched_cat

      assert patched_cat == cat2
      assert type == Cat
    end
  end

  test "diff/2 should always fail if structs are of different type" do
    check all(
            cat <- cat_generator(),
            dog <- dog_generator()
          ) do
      assert_raise(FunctionClauseError, fn ->
        Patch.diff(cat, dog)
      end)
    end
  end

  defp cat_generator do
    gen all(
          map <-
            StreamData.fixed_map(%{
              name: StreamData.binary(),
              cuteness: StreamData.integer()
            })
        ) do
      struct(Cat, map)
    end
  end

  defp dog_generator do
    gen all(
          map <-
            StreamData.fixed_map(%{
              name: StreamData.binary(),
              breed: StreamData.atom(:alphanumeric)
            })
        ) do
      struct(Dog, map)
    end
  end
end

defmodule PatchworkTest do
  use ExUnit.Case
  doctest Patchwork

  test "greets the world" do
    assert Patchwork.hello() == :world
  end
end

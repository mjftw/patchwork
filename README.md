# Patchwork

Patchwork is Elixir library for calculating the difference between two data structures, and applying that difference as a patch. Think git patches for for Elixir data structures.

This is useful when transferring data in a distributed system, as it allows you to transfer only the difference, rather than the whole data structure.

E.g.

```elixir
map1 = %{a: 1, b: 2, c: 3}
map2 = Map.put(map1, :d, 4)

patch = Patchwork.Patch.diff(map1, map2)

assert {:ok, map2} == Patchwork.Patch.apply(map1, patch)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `patchwork` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:patchwork, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/patchwork>.

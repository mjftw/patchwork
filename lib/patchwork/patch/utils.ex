defmodule Patchwork.Patch.Utils do
  def non_any_impl_for(value) do
    case Patchwork.Patch.impl_for(value) do
      impl when impl not in [Patchwork.Patch.Any, nil] -> impl
      _ -> nil
    end
  end
end

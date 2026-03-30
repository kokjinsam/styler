defmodule Styler.MixProjectTest do
  use ExUnit.Case, async: true

  test "ships credo as a compile-time dependency for consumers" do
    credo_dep =
      Enum.find(Mix.Project.config()[:deps], fn
        {:credo, _requirement, _opts} -> true
        _other -> false
      end)

    assert {:credo, "~> 1.7", opts} = credo_dep
    assert opts[:runtime] == false
    refute Keyword.has_key?(opts, :only)
  end
end

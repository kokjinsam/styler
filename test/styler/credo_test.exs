defmodule Styler.CredoTest do
  use ExUnit.Case, async: true

  @styler_replaced_checks [
    Credo.Check.Consistency.MultiAliasImportRequireUse,
    Credo.Check.Consistency.ParameterPatternMatching,
    Credo.Check.Design.AliasUsage,
    Credo.Check.Readability.AliasOrder,
    Credo.Check.Readability.BlockPipe,
    Credo.Check.Readability.LargeNumbers,
    Credo.Check.Readability.ModuleDoc,
    Credo.Check.Readability.MultiAlias,
    Credo.Check.Readability.OneArityFunctionInPipe,
    Credo.Check.Readability.ParenthesesOnZeroArityDefs,
    Credo.Check.Readability.PipeIntoAnonymousFunctions,
    Credo.Check.Readability.PreferImplicitTry,
    Credo.Check.Readability.SinglePipe,
    Credo.Check.Readability.StrictModuleLayout,
    Credo.Check.Readability.StringSigils,
    Credo.Check.Readability.UnnecessaryAliasExpansion,
    Credo.Check.Readability.WithSingleClause,
    Credo.Check.Refactor.CaseTrivialMatches,
    Credo.Check.Refactor.CondStatements,
    Credo.Check.Refactor.FilterCount,
    Credo.Check.Refactor.MapInto,
    Credo.Check.Refactor.MapJoin,
    Credo.Check.Refactor.NegatedConditionsInUnless,
    Credo.Check.Refactor.NegatedConditionsWithElse,
    Credo.Check.Refactor.PipeChainStart,
    Credo.Check.Refactor.RedundantWithClauseResult,
    Credo.Check.Refactor.UnlessWithElse,
    Credo.Check.Refactor.WithClauses
  ]

  describe "config/0" do
    test "returns a valid credo config map" do
      config = Styler.Credo.config()

      assert %{configs: [default]} = config
      assert default.name == "default"
      assert default.strict == true
      assert is_list(default.checks)
      assert length(default.checks) > 0
    end

    test "disables all Styler-replaced checks" do
      %{configs: [%{checks: checks}]} = Styler.Credo.config()

      for module <- @styler_replaced_checks do
        assert {^module, false} = Enum.find(checks, fn {m, _} -> m == module end),
               "Expected #{inspect(module)} to be disabled"
      end
    end
  end

  describe "config/1" do
    test "overrides a default check" do
      %{configs: [%{checks: checks}]} =
        Styler.Credo.config(checks: [{Credo.Check.Readability.MaxLineLength, [max_length: 100]}])

      assert {Credo.Check.Readability.MaxLineLength, [max_length: 100]} =
               Enum.find(checks, fn {m, _} -> m == Credo.Check.Readability.MaxLineLength end)
    end

    test "adds checks not in the default list" do
      %{configs: [%{checks: checks}]} =
        Styler.Credo.config(checks: [{Credo.Check.Readability.Specs, []}])

      # The default has Specs set to false, so override should win
      assert {Credo.Check.Readability.Specs, []} =
               Enum.find(checks, fn {m, _} -> m == Credo.Check.Readability.Specs end)
    end

    test "overrides top-level config" do
      %{configs: [config]} = Styler.Credo.config(strict: false, parse_timeout: 10_000)

      assert config.strict == false
      assert config.parse_timeout == 10_000
    end
  end
end

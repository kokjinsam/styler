defmodule Styler.Credo do
  @moduledoc """
  Provides a shared Credo configuration with Styler-overlapping rules already disabled.

  ## Usage

  In your project's `.credo.exs`:

      # .credo.exs
      Styler.Credo.config()

  To override specific checks, pass them as options:

      Styler.Credo.config(
        checks: [
          # Override a default check
          {Credo.Check.Readability.MaxLineLength, [max_length: 100]},
          # Disable a check
          {Credo.Check.Design.TagTODO, false}
        ]
      )

  To override top-level settings:

      Styler.Credo.config(strict: false, parse_timeout: 10_000)
  """

  @doc """
  Returns the full Credo configuration map with Styler-overlapping rules disabled.

  ## Options

    * `:checks` - A list of `{CheckModule, opts}` tuples to override defaults.
      Overrides are merged by check module — your value wins over the default.

    * Any other key (`:strict`, `:parse_timeout`, `:color`, `:files`, `:plugins`,
      `:requires`) overrides the corresponding top-level config value.
  """
  def config(overrides \\ []) do
    {check_overrides, config_overrides} = Keyword.pop(overrides, :checks, [])

    override_map = Map.new(check_overrides, fn
      {module, opts} -> {module, {module, opts}}
      module when is_atom(module) -> {module, {module, []}}
    end)

    merged_checks =
      Enum.map(default_checks(), fn {module, _opts} = check ->
        Map.get(override_map, module, check)
      end)

    # Append any overrides for checks not in the default list
    default_modules = MapSet.new(default_checks(), fn {module, _} -> module end)

    extra_checks =
      override_map
      |> Enum.reject(fn {module, _} -> MapSet.member?(default_modules, module) end)
      |> Enum.map(fn {_module, check} -> check end)

    config =
      default_config()
      |> Map.merge(Map.new(config_overrides))
      |> Map.put(:checks, merged_checks ++ extra_checks)

    %{configs: [config]}
  end

  defp default_config do
    %{
      name: "default",
      files: %{
        included: [
          "lib/",
          "src/",
          "test/",
          "web/",
          "apps/*/lib/",
          "apps/*/src/",
          "apps/*/test/",
          "apps/*/web/"
        ],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      plugins: [],
      requires: [],
      strict: true,
      parse_timeout: 5000,
      color: true
    }
  end

  defp default_checks do
    [
      # Consistency Checks
      {Credo.Check.Consistency.ExceptionNames, []},
      {Credo.Check.Consistency.LineEndings, []},
      {Credo.Check.Consistency.MultiAliasImportRequireUse, false},
      {Credo.Check.Consistency.ParameterPatternMatching, false},
      {Credo.Check.Consistency.SpaceAroundOperators, []},
      {Credo.Check.Consistency.SpaceInParentheses, []},
      {Credo.Check.Consistency.TabsOrSpaces, []},
      {Credo.Check.Consistency.UnusedVariableNames, []},

      # Design Checks
      {Credo.Check.Design.AliasUsage, false},
      {Credo.Check.Design.DuplicatedCode, []},
      {Credo.Check.Design.SkipTestWithoutComment, []},
      {Credo.Check.Design.TagFIXME, []},
      {Credo.Check.Design.TagTODO, [exit_status: 2]},

      # Readability Checks
      {Credo.Check.Readability.AliasAs, []},
      {Credo.Check.Readability.AliasOrder, false},
      {Credo.Check.Readability.BlockPipe, false},
      {Credo.Check.Readability.FunctionNames, []},
      {Credo.Check.Readability.ImplTrue, []},
      {Credo.Check.Readability.LargeNumbers, false},
      {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
      {Credo.Check.Readability.ModuleAttributeNames, []},
      {Credo.Check.Readability.ModuleDoc, false},
      {Credo.Check.Readability.ModuleNames, []},
      {Credo.Check.Readability.MultiAlias, false},
      {Credo.Check.Readability.NestedFunctionCalls, []},
      {Credo.Check.Readability.OneArityFunctionInPipe, false},
      {Credo.Check.Readability.OnePipePerLine, []},
      {Credo.Check.Readability.ParenthesesInCondition, []},
      {Credo.Check.Readability.ParenthesesOnZeroArityDefs, false},
      {Credo.Check.Readability.PipeIntoAnonymousFunctions, false},
      {Credo.Check.Readability.PredicateFunctionNames, []},
      {Credo.Check.Readability.PreferImplicitTry, false},
      {Credo.Check.Readability.PreferUnquotedAtoms, false},
      {Credo.Check.Readability.RedundantBlankLines, []},
      {Credo.Check.Readability.Semicolons, []},
      {Credo.Check.Readability.SeparateAliasRequire, []},
      {Credo.Check.Readability.SingleFunctionToBlockPipe, []},
      {Credo.Check.Readability.SinglePipe, false},
      {Credo.Check.Readability.SpaceAfterCommas, []},
      {Credo.Check.Readability.Specs, false},
      {Credo.Check.Readability.StrictModuleLayout, false},
      {Credo.Check.Readability.StringSigils, false},
      {Credo.Check.Readability.TrailingBlankLine, []},
      {Credo.Check.Readability.TrailingWhiteSpace, []},
      {Credo.Check.Readability.UnnecessaryAliasExpansion, false},
      {Credo.Check.Readability.VariableNames, []},
      {Credo.Check.Readability.WithCustomTaggedTuple, []},
      {Credo.Check.Readability.WithSingleClause, false},

      # Refactoring Opportunities
      {Credo.Check.Refactor.ABCSize, false},
      {Credo.Check.Refactor.AppendSingleItem, []},
      {Credo.Check.Refactor.Apply, []},
      {Credo.Check.Refactor.CaseTrivialMatches, false},
      {Credo.Check.Refactor.CondInsteadOfIfElse, false},
      {Credo.Check.Refactor.CondStatements, false},
      {Credo.Check.Refactor.CyclomaticComplexity, []},
      {Credo.Check.Refactor.DoubleBooleanNegation, []},
      {Credo.Check.Refactor.FilterCount, false},
      {Credo.Check.Refactor.FilterFilter, []},
      {Credo.Check.Refactor.FilterReject, []},
      {Credo.Check.Refactor.FunctionArity, []},
      {Credo.Check.Refactor.IoPuts, []},
      {Credo.Check.Refactor.LongQuoteBlocks, []},
      {Credo.Check.Refactor.MapInto, false},
      {Credo.Check.Refactor.MapJoin, false},
      {Credo.Check.Refactor.MapMap, []},
      {Credo.Check.Refactor.MatchInCondition, []},
      {Credo.Check.Refactor.ModuleDependencies, false},
      {Credo.Check.Refactor.NegatedConditionsInUnless, false},
      {Credo.Check.Refactor.NegatedConditionsWithElse, false},
      {Credo.Check.Refactor.NegatedIsNil, []},
      {Credo.Check.Refactor.Nesting, []},
      {Credo.Check.Refactor.PassAsyncInTestCases, []},
      {Credo.Check.Refactor.PerceivedComplexity, []},
      {Credo.Check.Refactor.PipeChainStart, false},
      {Credo.Check.Refactor.RedundantWithClauseResult, false},
      {Credo.Check.Refactor.RejectFilter, []},
      {Credo.Check.Refactor.RejectReject, []},
      {Credo.Check.Refactor.UnlessWithElse, false},
      {Credo.Check.Refactor.UtcNowTruncate, []},
      {Credo.Check.Refactor.VariableRebinding, []},
      {Credo.Check.Refactor.WithClauses, false},

      # Warnings
      {Credo.Check.Warning.ApplicationConfigInModuleAttribute, []},
      {Credo.Check.Warning.BoolOperationOnSameValues, []},
      {Credo.Check.Warning.Dbg, []},
      {Credo.Check.Warning.ExpensiveEmptyEnumCheck, []},
      {Credo.Check.Warning.IExPry, []},
      {Credo.Check.Warning.IoInspect, []},
      {Credo.Check.Warning.LazyLogging, false},
      {Credo.Check.Warning.LeakyEnvironment, []},
      {Credo.Check.Warning.MapGetUnsafePass, []},
      {Credo.Check.Warning.MissedMetadataKeyInLoggerConfig, []},
      {Credo.Check.Warning.MixEnv, []},
      {Credo.Check.Warning.OperationOnSameValues, []},
      {Credo.Check.Warning.OperationWithConstantResult, []},
      {Credo.Check.Warning.RaiseInsideRescue, []},
      {Credo.Check.Warning.SpecWithStruct, []},
      {Credo.Check.Warning.StructFieldAmount, []},
      {Credo.Check.Warning.UnsafeExec, []},
      {Credo.Check.Warning.UnsafeToAtom, []},
      {Credo.Check.Warning.UnusedEnumOperation, []},
      {Credo.Check.Warning.UnusedFileOperation, []},
      {Credo.Check.Warning.UnusedKeywordOperation, []},
      {Credo.Check.Warning.UnusedListOperation, []},
      {Credo.Check.Warning.UnusedMapOperation, []},
      {Credo.Check.Warning.UnusedPathOperation, []},
      {Credo.Check.Warning.UnusedRegexOperation, []},
      {Credo.Check.Warning.UnusedStringOperation, []},
      {Credo.Check.Warning.UnusedTupleOperation, []},
      {Credo.Check.Warning.WrongTestFilename, []}
    ]
  end
end

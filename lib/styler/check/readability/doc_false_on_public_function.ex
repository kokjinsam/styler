defmodule Styler.Check.Readability.DocFalseOnPublicFunction do
  @moduledoc false
  use Credo.Check,
    base_priority: :low,
    category: :readability,
    param_defaults: [min_count: 2],
    explanations: [
      check: """
      Multiple `@doc false` on public functions in the same module is a
      code smell — typically cargo-culted from Phoenix generators.

      A single `@doc false` is a deliberate choice. But when an LLM
      sprays it across every function, it's hiding the API surface.

          # bad — every public function has @doc false
          defmodule MyAppWeb.UserController do
            @doc false
            def index(conn, _params), do: ...

            @doc false
            def show(conn, %{"id" => id}), do: ...

            @doc false
            def create(conn, %{"user" => params}), do: ...
          end

          # good — either document or make private
          defmodule MyAppWeb.UserController do
            def index(conn, _params), do: ...
            def show(conn, %{"id" => id}), do: ...
          end
      """,
      params: [
        min_count: "Minimum `@doc false` count per module to trigger (default: 2)."
      ]
    ]

  @otp_callbacks ~w(child_spec start_link init terminate code_change
    handle_call handle_cast handle_info handle_continue format_status)a

  @dunder_functions ~w(__using__ __before_compile__ __after_compile__
    __changeset__ __struct__ __schema__ __fields__ __resource__)a

  @doc false
  @impl Credo.Check
  def run(%SourceFile{} = source_file, params) do
    min_count = Params.get(params, :min_count, __MODULE__)
    ctx = Context.build(source_file, params, __MODULE__)

    {hits, _pending} =
      Credo.Code.prewalk(source_file, &walk/2, {[], false})

    if length(hits) >= min_count do
      hits
      |> Enum.reduce(ctx, fn {meta, name}, ctx ->
        put_issue(ctx, issue_for(ctx, meta, name))
      end)
      |> Map.get(:issues, [])
    else
      []
    end
  end

  defp walk({:@, _, [{:doc, _, [false]}]} = ast, {hits, _}) do
    {ast, {hits, true}}
  end

  defp walk({:@, _, [{:impl, _, [true]}]} = ast, {hits, _}) do
    {ast, {hits, false}}
  end

  defp walk({:@, _, [{:impl, _, [{:__block__, _, [true]}]}]} = ast, {hits, _}) do
    {ast, {hits, false}}
  end

  defp walk({:def, meta, [{name, _, _} | _]} = ast, {hits, true}) when is_atom(name) do
    if exempt?(name) do
      {ast, {hits, false}}
    else
      {ast, {[{meta, name} | hits], false}}
    end
  end

  defp walk({:defp, _, _} = ast, {hits, _}) do
    {ast, {hits, false}}
  end

  defp walk({:@, _, [{attr, _, _}]} = ast, {hits, _}) when attr in [:doc, :moduledoc] do
    {ast, {hits, false}}
  end

  defp walk(ast, acc), do: {ast, acc}

  defp exempt?(name), do: name in @otp_callbacks or name in @dunder_functions

  defp issue_for(ctx, meta, name) do
    format_issue(ctx,
      message: "`@doc false` on public `def #{name}` — document it or make it `defp`.",
      trigger: "@doc false",
      line_no: meta[:line]
    )
  end
end

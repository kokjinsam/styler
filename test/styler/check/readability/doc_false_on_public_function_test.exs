defmodule Styler.Check.Readability.DocFalseOnPublicFunctionTest do
  use Credo.Test.Case

  alias Styler.Check.Readability.DocFalseOnPublicFunction

  test "reports multiple @doc false on public functions" do
    """
    defmodule Test do
      @doc false
      def index(conn, params), do: conn

      @doc false
      def show(conn, params), do: conn
    end
    """
    |> to_source_file()
    |> run_check(DocFalseOnPublicFunction)
    |> assert_issues(fn issues -> assert length(issues) == 2 end)
  end

  test "does NOT report a single @doc false" do
    """
    defmodule Test do
      @doc false
      def internal_helper(x), do: x

      def public_api(x), do: x
    end
    """
    |> to_source_file()
    |> run_check(DocFalseOnPublicFunction)
    |> refute_issues()
  end

  test "does NOT report @doc false on defp" do
    """
    defmodule Test do
      @doc false
      defp a(x), do: x

      @doc false
      defp b(x), do: x
    end
    """
    |> to_source_file()
    |> run_check(DocFalseOnPublicFunction)
    |> refute_issues()
  end

  test "does NOT report @doc false with @impl true" do
    """
    defmodule Test do
      @doc false
      @impl true
      def handle_call(msg, from, state), do: {:reply, :ok, state}

      @doc false
      @impl true
      def handle_cast(msg, state), do: {:noreply, state}
    end
    """
    |> to_source_file()
    |> run_check(DocFalseOnPublicFunction)
    |> refute_issues()
  end

  test "does NOT report @doc false on OTP callbacks" do
    """
    defmodule Test do
      @doc false
      def child_spec(opts), do: opts

      @doc false
      def init(args), do: {:ok, args}
    end
    """
    |> to_source_file()
    |> run_check(DocFalseOnPublicFunction)
    |> refute_issues()
  end

  test "respects configurable min_count" do
    """
    defmodule Test do
      @doc false
      def a(x), do: x

      @doc false
      def b(x), do: x

      @doc false
      def c(x), do: x
    end
    """
    |> to_source_file()
    |> run_check(DocFalseOnPublicFunction, min_count: 3)
    |> assert_issues(fn issues -> assert length(issues) == 3 end)
  end

  test "does NOT report below configurable min_count" do
    """
    defmodule Test do
      @doc false
      def a(x), do: x

      @doc false
      def b(x), do: x
    end
    """
    |> to_source_file()
    |> run_check(DocFalseOnPublicFunction, min_count: 3)
    |> refute_issues()
  end
end

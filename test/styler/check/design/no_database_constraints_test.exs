defmodule Styler.Check.Design.NoDatabaseConstraintsTest do
  use Credo.Test.Case, async: true

  alias Styler.Check.Design.NoDatabaseConstraints

  test "reports forbidden add options inside create table blocks" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        create table(:products) do
          add :price, :decimal, null: false, precision: 10, scale: 2, default: 0
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> assert_issue(%{
      line_no: 6,
      trigger: "add",
      message:
        "Column option(s) `null`, `precision`, `scale`, `default` should not be set in migrations. Enforce at the application layer."
    })
  end

  test "does not report bare add calls inside create table blocks" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        create table(:users) do
          add :name, :string
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> refute_issues()
  end

  test "does not report primary key columns with only allowed options" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        create table(:widgets, primary_key: false) do
          add :id, :binary_id, primary_key: true
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> refute_issues()
  end

  test "reports only the violating add calls in a block" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        create table(:users) do
          add :name, :string
          add :email, :string, null: false
          add :age, :integer
          add :status, :string, default: "active"
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> assert_issues(2)
    |> assert_issues_match([
      %{
        line_no: 7,
        trigger: "add",
        message: "Column option(s) `null` should not be set in migrations. Enforce at the application layer."
      },
      %{
        line_no: 9,
        trigger: "add",
        message: "Column option(s) `default` should not be set in migrations. Enforce at the application layer."
      }
    ])
  end

  test "reports forbidden modify options inside alter table blocks" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        alter table(:users) do
          modify :name, :string, from: :text, null: false, default: ""
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> assert_issue(%{
      line_no: 6,
      trigger: "modify",
      message: "Column option(s) `null`, `default` should not be set in migrations. Enforce at the application layer."
    })
  end

  test "reports forbidden add options inside alter table blocks" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        alter table(:users) do
          add :status, :string, null: false, size: 16
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> assert_issue(%{
      line_no: 6,
      trigger: "add",
      message: "Column option(s) `null`, `size` should not be set in migrations. Enforce at the application layer."
    })
  end

  test "does not report non-migration files" do
    """
    defmodule NotAMigration do
      def change do
        create table(:users) do
          add :name, :string, null: false
        end
      end
    end
    """
    |> to_source_file("not_a_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> refute_issues()
  end

  test "does not report add calls outside create table blocks" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        add :name, :string, null: false
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> refute_issues()
  end

  test "does not report timestamps inside create table blocks" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        create table(:users) do
          add :name, :string
          timestamps()
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> refute_issues()
  end

  test "does not report primary key columns" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        create table(:widgets, primary_key: false) do
          add :id, :binary_id,
            primary_key: true,
            null: false,
            default: fragment("gen_random_uuid()")
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> refute_issues()
  end

  test "reports top-level forbidden options on reference columns" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        create table(:comments) do
          add :post_id, references(:posts), null: false
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> assert_issue(%{
      line_no: 6,
      trigger: "add",
      message: "Column option(s) `null` should not be set in migrations. Enforce at the application layer."
    })
  end

  test "does not report forbidden options nested inside references" do
    """
    defmodule SampleMigration do
      use Ecto.Migration

      def change do
        create table(:comments) do
          add :post_id, references(:posts, null: false)
        end
      end
    end
    """
    |> to_source_file("sample_migration.ex")
    |> run_check(NoDatabaseConstraints)
    |> refute_issues()
  end
end

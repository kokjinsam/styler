# Spec: Styler.Check.Design.NoDatabaseConstraints

## Summary

A Credo check that flags forbidden column options in Ecto migration `add/3` and `modify/3` calls. Enforces the principle that business logic constraints belong in the application layer, not the database layer.

## Type

Credo rule (warn only, no auto-fix). Bundled in the Styler repo and enabled by default in `Styler.Credo.config()`.

## Motivation

Coding agents and developers routinely add database-level constraints like `null: false` and `default: value` to migrations. These should be enforced at the application layer (e.g., Ecto changesets) to keep the database schema as simple as possible.

## Detection

The check identifies migration files by inspecting the AST for `use Ecto.Migration`. File path is not used for detection.

## Targeted Functions

- `add/3` (inside `create table` blocks)
- `modify/3` (inside `alter table` blocks)

### Not Targeted

- `timestamps()` -- left alone, it's framework convention
- `create constraint()` -- separate rule (out of scope)
- `create index()` / `create unique_index()` -- separate rule (out of scope)
- `references()` -- separate rule (out of scope)

## Forbidden Options

The following keyword options on `add/3` and `modify/3` are flagged:

| Option      | Example                        |
|-------------|--------------------------------|
| `null`      | `null: false`                  |
| `default`   | `default: ""`                  |
| `size`      | `size: 255`                    |
| `precision` | `precision: 10`                |
| `scale`     | `scale: 2`                     |

### Allowed Options

- `primary_key: true` -- structural, not business logic
- Any option on a column that has `primary_key: true` is exempt (e.g., `default: fragment("gen_random_uuid()")` on a PK column)

## Not Configurable

All five forbidden options are always enforced. There are no params to customize which options are flagged.

## Severity

`higher` (error-level). Will cause non-zero exit status in strict mode.

## Reporting

One issue per `add`/`modify` call. If a single call has multiple forbidden options (e.g., `null: false, default: ""`), they are listed together in one issue.

### Message Format

```
Column option(s) `null`, `default` should not be set in migrations. Enforce at the application layer.
```

The message lists only the forbidden option keys found on that call.

## Scope

Applies to all migration files (detected via `use Ecto.Migration`), regardless of age. Users can disable the check on specific lines using Credo's inline `# credo:disable-for-next-line` comment.

## Integration with Styler.Credo

The check is enabled by default in `Styler.Credo.config()`. Consuming projects get it automatically.

## File Location

- Check module: `lib/checks/design/no_database_constraints.ex`
- Test: `test/checks/design/no_database_constraints_test.exs`

## Examples

### Flagged

```elixir
# Single forbidden option
add :name, :string, null: false
# => Column option(s) `null` should not be set in migrations. Enforce at the application layer.

# Multiple forbidden options
add :price, :decimal, null: false, precision: 10, scale: 2, default: 0
# => Column option(s) `null`, `precision`, `scale`, `default` should not be set in migrations. Enforce at the application layer.

# modify is also flagged
modify :name, :string, null: true, default: ""
# => Column option(s) `null`, `default` should not be set in migrations. Enforce at the application layer.

# size on varchar
add :code, :string, size: 6
# => Column option(s) `size` should not be set in migrations. Enforce at the application layer.
```

### Not Flagged

```elixir
# No forbidden options
add :name, :string

# primary_key is allowed
add :id, :binary_id, primary_key: true

# Primary key columns are fully exempt (default allowed here)
add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")

# timestamps() is left alone
timestamps()

# Bare type, no options
modify :status, :string
```

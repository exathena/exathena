# Used by "mix format"

locals_without_parens = [
  # IO
  configure: 2,
  item: 2,

  # Tests
  assert_changeset: 1,
  refute_changeset: 1,
  defmock: 2
]

[
  import_deps: [:ecto, :phoenix, :mox],
  inputs: ["{mix,.formatter}.exs", "sql-files/seeds.exs", "{lib,test,config}/**/*.{ex,exs}"],
  subdirectories: ["sql-files/*"],
  locals_without_parens: locals_without_parens
]

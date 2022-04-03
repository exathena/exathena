# Used by "mix format"

locals_without_parens = [
  # Tests
  assert_changeset: 1,
  refute_changeset: 1,
  defmock: 2
]

[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "{lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens
]

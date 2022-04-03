# Used by "mix format"
[
  import_deps: [:ecto, :phoenix],
  inputs: ["{mix,.formatter}.exs", "sql-files/seeds.exs", "config/**/*.{ex,exs}"],
  subdirectories: ["src/*", "sql-files/*"]
]

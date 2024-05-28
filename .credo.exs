%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["src/", "config/", "sql-files/"],
        excluded: [~r"/_build/", ~r"/mix/", ~r"/test/", ~r"/deps/", ~r"/node_modules/"]
      },
      plugins: [],
      requires: [],
      strict: true,
      parse_timeout: 5000,
      color: true
    }
  ]
}

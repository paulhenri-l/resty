# When using travis, run tests with this command:
# mix test --include external:true

Fakes.TestDB.start_link()
ExUnit.configure(exclude: [external: true])
ExUnit.start()

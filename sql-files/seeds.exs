# Script for populating the database.

ExAthena.Accounts.create_user!(%{
  id: 1,
  username: "admin",
  password: "admin",
  email: "athena@athena.com",
  role: :admin
})

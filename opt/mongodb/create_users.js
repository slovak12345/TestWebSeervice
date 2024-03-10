db.createUser({
    user: "myUser",
    pwd: "myPassowrd",
    roles: [
      { role: "readWrite", db: "my_database" },
      { role: "read", db: "another_database" }
    ]
  })
  
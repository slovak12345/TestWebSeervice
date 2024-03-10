db.createUser({
    user: "myUser",
    pwd: "myPassword",
    roles: [
      { role: "readWrite", db: "my_database" },
      { role: "read", db: "another_database" }
    ]
  })
  
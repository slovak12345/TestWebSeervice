db.createUser({
    user: "myUser",
    pwd: "myPassword",
    roles: [
      { role: "readWrite", db: "database" }
    ]
  })
  
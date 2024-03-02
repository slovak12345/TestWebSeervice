db.createUser({
    user: "gcs-mongodb",
    pwd: "onsdfs",
    roles: [
      { role: "readWrite", db: "my_database" },
      { role: "read", db: "another_database" }
    ]
  })
  
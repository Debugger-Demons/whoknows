## 1. Setting up PostgreSQL with Docker Compose with commentary

Created a `.env` file to store database credentials, so it can speak to our database container

```env
POSTGRES_DB=dbpractice
POSTGRES_USER=userpractice
POSTGRES_PASSWORD=passwordpractice
POSTGRES_HOST=localhost
```

Configured my knexfile.js so it can read my env variables

```javascript
import "dotenv/config";

export default {
  client: "postgresql",
  connection: {
    database: process.env.POSTGRES_DB,
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    host: process.env.POSTGRES_HOST,
  },
  migrations: {
    tableName: "knex_migrations",
  },
};
```

Created the migration file with this command:
npx knex migrate:make create_users_products_table

Edited my migration file so it contains the users and products table

```javascript
export function up(knex) {
  return knex.schema
    .createTable("users", (table) => {
      table.increments("id");
      table.string("first_name", 255).notNullable();
      table.string("last_name", 255).notNullable();
    })
    .createTable("products", (table) => {
      table.increments("id");
      table.decimal("price").notNullable();
      table.string("name", 1000).notNullable();
    });
}

export function down(knex) {
  return knex.schema.dropTable("products").dropTable("users");
}
```

Creating the seed file so we can have some dummy data in the file. Basically we can use this command to fill our postgresql db with the users.

npx knex seed:make seed_users

```javascript
export async function seed(knex) {
  await knex("users").del();

  await knex("users").insert([
    { id: 1, first_name: "John", last_name: "Doe" },
    { id: 2, first_name: "Jane", last_name: "Smith" },
    { id: 3, first_name: "Alice", last_name: "Johnson" },
  ]);
}
```

Use this command to run it.

npx knex seed:run

## Step by step guide on how to migrate from sqlite to postgresql

This is a step-by-step guide for transferring data from **SQLite to PostgreSQL** using **Knex.js**. Ideal if you've outgrown SQLite and want to move to a production-ready PostgreSQL setup.

---

### ✅ 1. Ensure your schema is the same

- Make sure the same tables and columns exist in both SQLite and PostgreSQL.
- If you're using Knex migrations, simply run the same migration on the PostgreSQL database.

---

### ✅ 2. Define both databases in your Knex config

- In `knexfile.js`, add two environments:
  - One for **SQLite**
  - One for **PostgreSQL**
- This allows you to connect to both databases inside your custom migration script.

---

### ✅ 3. Write a custom migration script (outside the seed system)

- Create a new JavaScript file (e.g., `migrateData.js`).
- In this script, connect to both databases using `knex(knexConfig.sqlite)` and `knex(knexConfig.postgres)`.

---

### ✅ 4. Fetch data from SQLite

- Use Knex to query the table(s) you want to migrate (e.g., `users`, `products`).
- Store the retrieved rows in memory (usually as arrays of objects).

---

### ✅ 5. Insert data into PostgreSQL

- Loop through the SQLite data and insert it into the corresponding PostgreSQL tables.
- Use conflict-handling logic if needed (e.g., `.onConflict('id').ignore()`).

---

### ✅ 6. Repeat for each table

- If migrating multiple tables, repeat the same fetch-insert pattern.
- Be aware of **foreign key relationships** — insert parent data (e.g., `users`) before child data (e.g., `orders`).

---

### ✅ 7. Test your data

- After the script runs, connect to the PostgreSQL database.
- Use SQL queries (`SELECT * FROM ...`) or GUI tools (pgAdmin, DBeaver) to verify data integrity.

---

### ✅ 8. Clean up

- Optionally remove or archive the old SQLite file.
- Document your migration logic in comments or logs for future reference.

---

### 🧠 Tips

- Always **backup your data** before running any migration.
- Wrap large operations in transactions if needed.
- Use conflict resolution methods (like `.onConflict()`) to avoid errors.
- If you have a huge dataset, consider batching or pagination.

---

This process is ideal for one-time migrations or transition projects where you're upgrading your stack from SQLite to PostgreSQL while keeping control over the data structure and flow.

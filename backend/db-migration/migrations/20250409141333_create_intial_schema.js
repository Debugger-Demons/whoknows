/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
export function up (knex) {
  return knex.schema
    .createTable("users", function (table) {
      table.increments("id");
      table.string("username").notNullable().unique();
      table.string("email").notNullable().unique();
      table.string("password").notNullable();
    })
    .then(() => {
      return knex.schema.createTable("pages", function (table) {
        table.string("title").primary().unique();
        table.string("url").notNullable().unique();
        table
          .string("language")
          .notNullable()
          .defaultTo("en")
          .checkIn(["en", "da"]);
        table.timestamp("last_updated");
        table.text("content").notNullable();
      });
    });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
export function down(knex) {
  return knex.schema.dropTableIfExists("pages").then(() => {
    return knex.schema.dropTableIfExists("users");
  });
};

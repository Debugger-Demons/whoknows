/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function (knex) {
  knex.schema.createTable("users", function (table) {
    table.increments("id");
    table.string("username").notNullable().unique();
    table.string("email").notNullable().unique();
    table.string("password").notNullable();
  });
  knex.schema.createTable('pages', function(table){
    table.string('title').primary().unique();
    table.string('url').notNullable().unique();
    table.string('language').notNullable();
    table.string('content').notNullable();
  })
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function (knex) {
  knex.schema.dropTableIfExists("users");
  knex.schema.dropTableIfExists("pages");
};

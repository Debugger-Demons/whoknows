/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
export async function seed(knex) {
  await knex('users').del()
  await knex('users').insert([
    {username: 'admin', email: 'test@test.dk', password: 'password'},
  ]);
};

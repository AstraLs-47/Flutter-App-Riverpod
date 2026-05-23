const fs = require('fs');
const path = require('path');
const pool = require('./config/db');

async function initializeDatabase() {
  try {
    console.log('Initializing database...');

    // Read the schema file
    const schemaPath = path.join(__dirname, 'config', 'schema.sql');
    const schemaSQL = fs.readFileSync(schemaPath, 'utf8');

    // Execute the entire schema as one query
    console.log('Executing database schema...');
    await pool.query(schemaSQL);

    console.log('Database initialized successfully!');
  } catch (error) {
    console.error('Error initializing database:', error);
    throw error;
  } finally {
    await pool.end();
  }
}

// Run if called directly
if (require.main === module) {
  initializeDatabase()
    .then(() => process.exit(0))
    .catch(() => process.exit(1));
}

module.exports = initializeDatabase;
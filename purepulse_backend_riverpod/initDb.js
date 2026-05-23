const pool = require('./src/config/db');
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcrypt');

const initDb = async () => {
  try {
    const schemaPath = path.join(__dirname, 'src', 'config', 'schema.sql');
    let sql = fs.readFileSync(schemaPath, 'utf8');

    const adminEmail = process.env.SEED_ADMIN_EMAIL;
    const adminPassword = process.env.SEED_ADMIN_PASSWORD;

    if (!adminEmail || !adminPassword) {
      throw new Error('SEED_ADMIN_EMAIL or SEED_ADMIN_PASSWORD is not defined in .env');
    }

    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(adminPassword, saltRounds);

    // Inject the credentials and generated hash into the SQL script
    sql = sql.replace('ADMIN_EMAIL_PLACEHOLDER', adminEmail);
    sql = sql.replace('ADMIN_PASSWORD_PLACEHOLDER', hashedPassword);

    console.log("🚀 Initializing database schema...");
    await pool.query(sql);
    console.log("✅ Database tables created successfully.");
    // Ensure uploads directory exists for image storage
    const uploadsDir = path.join(__dirname, 'uploads');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
      console.log("✅ Uploads directory created.");
    }
  } catch (err) {
    console.error("❌ Database initialization failed:", err.message);
  } finally {
    // Close the pool so the script can exit
    await pool.end();
  }
};

initDb();

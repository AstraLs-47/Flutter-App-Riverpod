const { Pool } = require('pg');
require('dotenv').config();
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
(async () => {
  try {
    const res = await pool.query("SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name");
    console.log('tables:', res.rows.map(r => r.table_name).join(', '));
    const names = ['users','user_profiles','categories','exercises','progress_entries','health_metrics','products','announcements','activity_logs'];
    for (const name of names) {
      try {
        const c = await pool.query(`SELECT COUNT(*) FROM ${name}`);
        console.log(name, 'count', c.rows[0].count);
      } catch (e) {
        console.error('table error', name, e.message);
      }
    }
  } catch (e) {
    console.error('error', e.message);
  } finally {
    await pool.end();
  }
})();

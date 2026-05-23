const pool = require('../config/db');

class AdminStats {
  static async getUserStats() {
    const result = await pool.query(`
      SELECT 
        COUNT(*) as total_users,
        COUNT(CASE WHEN role = 'admin' THEN 1 END) as admin_count,
        COUNT(CASE WHEN role = 'user' THEN 1 END) as regular_user_count,
        COUNT(CASE WHEN created_at > NOW() - INTERVAL '30 days' THEN 1 END) as new_users_30_days
      FROM users
    `);
    return result.rows[0];
  }

  static async getExerciseStats() {
    const result = await pool.query(`
      SELECT 
        COUNT(*) as total_exercises,
        COUNT(DISTINCT category_id) as categories_used
      FROM exercises
    `);
    return result.rows[0];
  }

  static async getProgressStats() {
    const result = await pool.query(`
      SELECT 
        COUNT(*) as total_entries,
        COUNT(DISTINCT user_id) as active_users,
        SUM(duration_minutes) as total_minutes,
        0 as total_volume
      FROM progress_entries
      WHERE entry_date > NOW() - INTERVAL '30 days'
    `);
    return result.rows[0];
  }

  static async getHealthStats() {
    const result = await pool.query(`
      SELECT 
        COUNT(*) as total_entries,
        COUNT(DISTINCT user_id) as users_tracking
      FROM health_metrics
    `);
    return result.rows[0];
  }

  static async getProductStats() {
    const result = await pool.query(`
      SELECT 
        COUNT(*) as total_products,
        COUNT(CASE WHEN is_active = true THEN 1 END) as active_products,
        SUM(stock_quantity) as total_stock,
        AVG(price) as average_price
      FROM products
    `);
    return result.rows[0];
  }

  static async getExerciseCategoryBreakdown() {
    const result = await pool.query(`
      SELECT COALESCE(c.name, 'Uncategorized') as category, COUNT(*) as count
      FROM exercises e
      LEFT JOIN categories c ON e.category_id = c.id
      GROUP BY COALESCE(c.name, 'Uncategorized')
      ORDER BY count DESC
    `);
    return result.rows;
  }

  static async getProductCategoryBreakdown() {
    const result = await pool.query(`
      SELECT COALESCE(category, 'Uncategorized') as category, COUNT(*) as count
      FROM products
      GROUP BY COALESCE(category, 'Uncategorized')
      ORDER BY count DESC
    `);
    return result.rows;
  }

  static async getAnnouncementCount() {
    const result = await pool.query(`
      SELECT COUNT(*) as total_announcements FROM announcements
    `);
    return result.rows[0];
  }

  static async getProgressCount() {
    const result = await pool.query(`
      SELECT COUNT(*) as total_entries FROM progress_entries
    `);
    return result.rows[0];
  }

  static async getProgressLast7Days() {
    const result = await pool.query(`
      SELECT to_char(d.day, 'YYYY-MM-DD') as date, COALESCE(counts.count, 0) as count
      FROM generate_series(CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE, INTERVAL '1 day') AS d(day)
      LEFT JOIN (
        SELECT entry_date, COUNT(*) as count
        FROM progress_entries
        WHERE entry_date >= CURRENT_DATE - INTERVAL '6 days'
        GROUP BY entry_date
      ) counts ON counts.entry_date = d.day
      ORDER BY d.day
    `);
    return result.rows;
  }

  static async getRecentProgressActivities(limit = 4) {
    const result = await pool.query(`
      SELECT p.id, p.user_id, u.email as user_email, u.first_name, u.last_name,
             p.exercise_id, e.name as exercise_name, p.weight, p.reps, p.sets,
             p.duration_minutes, p.notes, p.entry_date, p.created_at
      FROM progress_entries p
      LEFT JOIN users u ON p.user_id = u.id
      LEFT JOIN exercises e ON p.exercise_id = e.id
      ORDER BY p.created_at DESC
      LIMIT $1
    `, [limit]);
    return result.rows;
  }

  static async getProgressWeeklyTotal() {
    const result = await pool.query(`
      SELECT COUNT(*) as total_weekly_entries
      FROM progress_entries
      WHERE entry_date >= CURRENT_DATE - INTERVAL '6 days'
    `);
    return result.rows[0];
  }

  static async getHealthLast7Days() {
    const result = await pool.query(`
      SELECT to_char(d.day, 'YYYY-MM-DD') as date, COALESCE(counts.count, 0) as count
      FROM generate_series(CURRENT_DATE - INTERVAL '6 days', CURRENT_DATE, INTERVAL '1 day') AS d(day)
      LEFT JOIN (
        SELECT date, COUNT(*) as count
        FROM health_metrics
        WHERE date >= CURRENT_DATE - INTERVAL '6 days'
        GROUP BY date
      ) counts ON counts.date = d.day
      ORDER BY d.day
    `);
    return result.rows;
  }

  static async getHealthBannerStats() {
    const result = await pool.query(`
      SELECT AVG(latest.bmi) as average_bmi, AVG(latest.resting_heart_rate) as average_heart_rate
      FROM (
        SELECT DISTINCT ON (user_id) bmi, resting_heart_rate
        FROM health_metrics
        WHERE bmi IS NOT NULL OR resting_heart_rate IS NOT NULL
        ORDER BY user_id, date DESC
      ) latest
    `);
    return result.rows[0];
  }

  static async getUserSignupStats(days = 30) {
    const result = await pool.query(`
      SELECT to_char(d.day, 'YYYY-MM-DD') as date, COALESCE(users_by_date.count, 0) as count
      FROM generate_series(CURRENT_DATE - ($1 || ' days')::interval, CURRENT_DATE, INTERVAL '1 day') AS d(day)
      LEFT JOIN (
        SELECT DATE(created_at) as signup_date, COUNT(*) as count
        FROM users
        GROUP BY DATE(created_at)
      ) users_by_date ON users_by_date.signup_date = d.day
      ORDER BY d.day
    `, [days]);
    return result.rows;
  }

  static async getRecentExercises(limit = 4) {
    const result = await pool.query(`
      SELECT id, name, description, category, created_at
      FROM exercises
      ORDER BY created_at DESC
      LIMIT $1
    `, [limit]);
    return result.rows;
  }

  static async getActivityLogs(limit = 100, offset = 0) {
    const result = await pool.query(
      `SELECT al.*, u.email as user_email, u.first_name, u.last_name
       FROM activity_logs al
       LEFT JOIN users u ON al.user_id = u.id
       ORDER BY al.created_at DESC LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    return result.rows;
  }

  static async getActivityStats() {
    const result = await pool.query(`
      SELECT 
        COUNT(*) as total_actions,
        COUNT(DISTINCT user_id) as active_users,
        COUNT(DISTINCT DATE(created_at)) as active_days
      FROM activity_logs
      WHERE created_at > NOW() - INTERVAL '30 days'
    `);
    return result.rows[0];
  }

  static async getDashboardSummary() {
const [userStats, exerciseStats, exerciseCategories, progressStats, progressLast7Days, progressRecent, progressWeekly, announcementCount, productStats, productCategories, healthLast7Days, healthBanner, activityStats, signupStats, recentExercises] = await Promise.all([
      AdminStats.getUserStats(),
      AdminStats.getExerciseStats(),
      AdminStats.getExerciseCategoryBreakdown(),
      AdminStats.getProgressStats(),
      AdminStats.getProgressLast7Days(),
      AdminStats.getRecentProgressActivities(),
      AdminStats.getProgressWeeklyTotal(),
      AdminStats.getAnnouncementCount(),
      AdminStats.getProductStats(),
      AdminStats.getProductCategoryBreakdown(),
      AdminStats.getHealthLast7Days(),
      AdminStats.getHealthBannerStats(),
      AdminStats.getActivityStats(),
      AdminStats.getUserSignupStats(30),
      AdminStats.getRecentExercises(4)
    ]);

    return {
      users: {
        total: parseInt(userStats.total_users, 10) || 0,
        admins: parseInt(userStats.admin_count, 10) || 0,
        regular: parseInt(userStats.regular_user_count, 10) || 0,
        newLast30Days: parseInt(userStats.new_users_30_days, 10) || 0
      },
      exercises: {
        total: parseInt(exerciseStats.total_exercises, 10) || 0,
        categoriesUsed: parseInt(exerciseStats.categories_used, 10) || 0,
        byCategory: exerciseCategories.map(row => ({ category: row.category, count: parseInt(row.count, 10) })),
        recentExercises: recentExercises.map(row => ({
          id: row.id,
          title: row.name,
          description: row.description,
          category: row.category,
          createdAt: row.created_at
        }))
      },
      products: {
        total: parseInt(productStats.total_products, 10) || 0,
        active: parseInt(productStats.active_products, 10) || 0,
        totalStock: parseInt(productStats.total_stock, 10) || 0,
        averagePrice: parseFloat(productStats.average_price) || 0,
        byCategory: productCategories.map(row => ({ category: row.category, count: parseInt(row.count, 10) }))
      },
      announcements: {
        total: parseInt(announcementCount.total_announcements, 10) || 0
      },
      progress: {
        totalEntries: parseInt(progressStats.total_entries, 10) || 0,
        entriesLast7Days: progressLast7Days.map(row => ({ date: row.date, count: parseInt(row.count, 10) })),
        weeklyTotal: parseInt(progressWeekly.total_weekly_entries, 10) || 0,
        recentActivities: progressRecent.map(entry => ({
          id: entry.id,
          userId: entry.user_id,
          userEmail: entry.user_email,
          userName: entry.first_name && entry.last_name ? `${entry.first_name} ${entry.last_name}` : null,
          exerciseId: entry.exercise_id,
          exerciseName: entry.exercise_name,
          weight: entry.weight,
          reps: entry.reps,
          sets: entry.sets,
          durationMinutes: entry.duration_minutes,
          notes: entry.notes,
          entryDate: entry.entry_date,
          createdAt: entry.created_at
        }))
      },
      health: {
        last7Days: healthLast7Days.map(row => ({ date: row.date, count: parseInt(row.count, 10) })),
        averageBmi: parseFloat(healthBanner.average_bmi) || 0,
        averageHeartRate: parseFloat(healthBanner.average_heart_rate) || 0
      },
      signupStats: signupStats.map(row => ({ date: row.date, count: parseInt(row.count, 10) })),
      activity: {
        actionsLast30Days: parseInt(activityStats.total_actions, 10) || 0,
        activeUsers: parseInt(activityStats.active_users, 10) || 0,
        activeDays: parseInt(activityStats.active_days, 10) || 0
      }
    };
  }

  static async logActivity(userId, action, entityType, entityId, metadata = {}, ipAddress = null, userAgent = null) {
    const result = await pool.query(
      `INSERT INTO activity_logs (user_id, action, entity_type, entity_id, metadata, ip_address, user_agent)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
      [userId, action, entityType, entityId, JSON.stringify(metadata), ipAddress, userAgent]
    );
    return result.rows[0];
  }
}

module.exports = AdminStats;

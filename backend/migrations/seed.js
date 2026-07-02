const { Pool } = require('pg');
const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'familyties',
  user: process.env.DB_USER || 'familyties',
  password: process.env.DB_PASSWORD || 'securepassword123',
});

async function seedDatabase() {
  try {
    console.log('Seeding database with sample data...');
    
    // Create families
    const family1Id = uuidv4();
    const family2Id = uuidv4();
    
    await pool.query(
      'INSERT INTO families (family_id, family_name, public_mission) VALUES ($1, $2, $3), ($4, $5, $6)',
      [family1Id, 'Tanaka-Jones Clan', 'Building stronger family bonds through technology', 
       family2Id, 'Smith-Williams Legacy', 'Preserving family heritage for generations']
    );
    
    console.log('✅ Sample families created');
    
    // Create houses
    const house1Id = uuidv4();
    const house2Id = uuidv4();
    
    await pool.query(
      'INSERT INTO houses (house_id, family_id, house_name, location_city, location_country) VALUES ($1, $2, $3, $4, $5), ($6, $7, $8, $9, $10)',
      [house1Id, family1Id, 'London House', 'London', 'UK',
       house2Id, family1Id, 'New York House', 'New York', 'USA']
    );
    
    console.log('✅ Sample houses created');
    
    // Create users
    const passwordHash = await bcrypt.hash('demo123456', 10);
    
    const user1Id = uuidv4();
    const user2Id = uuidv4();
    const user3Id = uuidv4();
    
    await pool.query(
      `INSERT INTO users (user_id, email, full_name, password_hash, family_id, house_id, birth_date, location_city, location_country, is_elder, ai_twin_opt_in) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11),
               ($12, $13, $14, $4, $5, $6, $15, $8, $9, $16, $11),
               ($17, $18, $19, $4, $5, $20, $21, $22, $23, $24, $11)`,
      [user1Id, 'grandpa@familyties.com', 'John Tanaka', passwordHash, family1Id, house1Id, '1940-01-15', 'London', 'UK', true, true,
       user2Id, 'parent@familyties.com', 'Sarah Jones', passwordHash, family1Id, house1Id, '1965-06-20', 'London', 'UK', false, true,
       user3Id, 'child@familyties.com', 'Alex Jones', passwordHash, family1Id, house2Id, '1995-03-10', 'New York', 'USA', false, true]
    );
    
    console.log('✅ Sample users created');
    console.log('\n📊 Sample Credentials:');
    console.log('  Email: grandpa@familyties.com | Password: demo123456');
    console.log('  Email: parent@familyties.com | Password: demo123456');
    console.log('  Email: child@familyties.com | Password: demo123456\n');
    
  } catch (error) {
    console.error('❌ Seeding error:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };

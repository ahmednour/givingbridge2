const { sequelize } = require('./src/config/db');

async function checkMigration() {
  try {
    const [results] = await sequelize.query('SHOW COLUMNS FROM donations LIKE "approvalStatus"');
    
    if (results.length > 0) {
      console.log('✅ approvalStatus column exists!');
      console.log(JSON.stringify(results[0], null, 2));
    } else {
      console.log('❌ approvalStatus column is missing');
    }
    
    // Check all approval-related columns
    const [allColumns] = await sequelize.query('SHOW COLUMNS FROM donations');
    const approvalColumns = allColumns.filter(col => 
      col.Field.includes('approval') || col.Field.includes('approved') || col.Field.includes('rejection')
    );
    
    console.log('\nApproval-related columns:');
    approvalColumns.forEach(col => {
      console.log(`  - ${col.Field}: ${col.Type}`);
    });
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await sequelize.close();
    process.exit();
  }
}

checkMigration();

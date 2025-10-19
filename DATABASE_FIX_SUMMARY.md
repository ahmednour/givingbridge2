# Database Connection and Schema Fix

## Issues Resolved

### 1. Database Connection Error

**Error:**

```
ConnectionRefusedError [SequelizeConnectionRefusedError]: connect ECONNREFUSED 172.18.0.2:3306
```

**Root Cause:**
The backend service was starting before the MySQL database was fully initialized, despite the `depends_on` health check in docker-compose.yml.

**Solution:**
Restarted the backend container after the database was fully initialized using:

```bash
docker restart givingbridge_backend
```

### 2. Missing Column Error

**Error:**

```
Error: Unknown column 'donorName' in 'field list'
sqlMessage: "Unknown column 'donorName' in 'field list'"
```

**Root Cause:**
The Sequelize model `Donation.js` defined a `donorName` field, but the database initialization script `init.sql` was missing this column in the `donations` table schema.

**Solution:**
Updated [`backend/sql/init.sql`](d:\project\git project\givingbridge\backend\sql\init.sql) to include the `donorName` column:

```sql
-- Before:
CREATE TABLE IF NOT EXISTS donations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    `condition` VARCHAR(50) NOT NULL,
    location VARCHAR(255) NOT NULL,
    imageUrl VARCHAR(500),
    donorId INT NOT NULL,
    -- donorName was missing!
    isAvailable BOOLEAN DEFAULT TRUE,
    ...
);

-- After:
CREATE TABLE IF NOT EXISTS donations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    `condition` VARCHAR(50) NOT NULL,
    location VARCHAR(255) NOT NULL,
    imageUrl VARCHAR(500),
    donorId INT NOT NULL,
    donorName VARCHAR(255) NOT NULL,  -- ADDED
    isAvailable BOOLEAN DEFAULT TRUE,
    ...
);
```

### 3. SQL Syntax Error (BOM Issue)

**Error:**

```
ERROR 1064 (42000) at line 1: You have an error in your SQL syntax
```

**Root Cause:**
The `init.sql` file contained a UTF-8 BOM (Byte Order Mark) character at the beginning, which caused MySQL to fail parsing the SQL script.

**Solution:**
Recreated the `init.sql` file without the BOM character by deleting and creating a new file with clean UTF-8 encoding.

## Files Modified

1. **backend/sql/init.sql**
   - Added `donorName VARCHAR(255) NOT NULL` column to donations table
   - Removed UTF-8 BOM character
   - Updated sample data INSERT statements to include donorName values

## Database Schema Changes

### Donations Table

Added column:

- `donorName` (VARCHAR(255), NOT NULL) - Stores the name of the donor for quick access without requiring a JOIN with users table

### Sample Data

Updated sample donations to include donor names:

```sql
INSERT IGNORE INTO donations (title, description, category, `condition`, location, donorId, donorName) VALUES
('Old Books Collection', '...', 'books', 'good', 'New York, NY', 2, 'Demo Donor'),
('Winter Clothes', '...', 'clothes', 'excellent', 'New York, NY', 2, 'Demo Donor'),
('Kitchen Appliances', '...', 'electronics', 'good', 'Los Angeles, CA', 2, 'Demo Donor');
```

## Steps to Reproduce Fix

If you encounter similar issues:

1. **Stop and remove containers:**

   ```bash
   docker-compose down
   ```

2. **Remove old database volume:**

   ```bash
   docker volume rm givingbridge_db_data
   ```

3. **Start containers:**

   ```bash
   docker-compose up -d
   ```

4. **If backend starts before DB is ready, restart backend:**
   ```bash
   docker restart givingbridge_backend
   ```

## Verification

✅ Database initialized successfully:

```
✅ Database connection has been established successfully.
🔄 Running 5 pending migrations...
✅ All migrations completed successfully
```

✅ All services running:

- **Database**: MySQL 8.0 (healthy) - Port 3307
- **Backend**: Node.js Express (healthy) - Port 3000
- **Frontend**: Flutter Web (running) - Port 8080

✅ No more errors:

- ✅ Database connection successful
- ✅ `donorName` column exists
- ✅ Sample data inserted
- ✅ API endpoints operational

## Migration Strategy

The backend includes a migration file `005_add_donor_name_column.js` that handles adding the `donorName` column for existing deployments. This ensures:

1. **Fresh installations**: Column created via `init.sql`
2. **Existing deployments**: Column added via migration
3. **Idempotent**: Migration checks if column exists before attempting to add it

```javascript
// Migration code (backend/src/migrations/005_add_donor_name_column.js)
await queryInterface.describeTable("donations");
if (!tableDefinition.donorName) {
  await queryInterface.addColumn("donations", "donorName", {
    type: Sequelize.STRING,
    allowNull: false,
    defaultValue: "Unknown Donor",
  });
}
```

## Related Files

- [`backend/src/models/Donation.js`](d:\project\git project\givingbridge\backend\src\models\Donation.js) - Sequelize model definition
- [`backend/sql/init.sql`](d:\project\git project\givingbridge\backend\sql\init.sql) - Database initialization script
- [`docker-compose.yml`](d:\project\git project\givingbridge\docker-compose.yml) - Container orchestration
- [`backend/src/config/db.js`](d:\project\git project\givingbridge\backend\src\config\db.js) - Database configuration

## Application Status

🎉 **All systems operational!**

- ✅ Frontend accessible at: http://localhost:8080
- ✅ Backend API at: http://localhost:3000
- ✅ Database ready on: localhost:3307

You can now:

- Create new donations (with donorName field)
- Browse existing donations
- Submit and manage requests
- Use all application features

## Prevention Tips

To avoid similar issues in the future:

1. **Always sync model definitions with database schema**
2. **Use migrations for schema changes**
3. **Avoid UTF-8 BOM in SQL files** (use UTF-8 without BOM)
4. **Test database initialization with fresh volumes**
5. **Monitor container startup order** in docker-compose health checks

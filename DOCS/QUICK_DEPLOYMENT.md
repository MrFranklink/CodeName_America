# ? Quick Deployment - 5 Minute Guide

## For Moving to Another Dev Machine

### Source Machine (Current System) - 2 Minutes

**1. Backup Database**
```sql
BACKUP DATABASE Banking_Details
TO DISK = 'D:\Banking_Backup.bak';
```

**2. Copy These Files:**
- `D:\Banking_Backup.bak`
- `D:\CodeName_America\` (entire folder)

---

### Target Machine (New System) - 3 Minutes

**1. Install** (if not already installed):
- SQL Server Express
- Visual Studio 2022
- SSMS

**2. Restore Database**
```sql
RESTORE DATABASE Banking_Details
FROM DISK = 'C:\Temp\Banking_Backup.bak'
WITH REPLACE;
```

**3. Update Connection String**

File: `Bank_App\Web.config`

Find this line:
```xml
data source=YOUR_OLD_SERVER;
```

Replace with:
```xml
data source=(local)\SQLEXPRESS;
```

**4. Run**
```
- Open solution in Visual Studio
- Press F5
```

**Done!** ?

---

## Alternative: Migration Scripts

If you **don't want to copy data**, just the database structure:

**On New Machine:**

1. Create empty database:
```sql
   CREATE DATABASE Banking_Details;
   ```

2. Run migration script:
   ```sql
   -- File: SQL_Scripts/MASTER_MIGRATION_SCRIPT.sql
   -- This applies all database changes
 ```

3. Create admin account:
   ```sql
   INSERT INTO Manager VALUES ('MGR001', 'Admin', 'ADMIN12345');
   INSERT INTO UserLogin VALUES ('USER0001', 'admin', 'Dummy', 'MANAGER', 'MGR001');
   ```

4. Update connection string and run

---

## Files You Created

| File | Purpose |
|------|---------|
| `MASTER_MIGRATION_SCRIPT.sql` | All database changes in one script |
| `DEPLOYMENT_GUIDE.md` | Complete deployment documentation |
| `QUICK_DEPLOYMENT.md` | This file - quick reference |

---

## Connection String Examples

**SQL Express (default):**
```
data source=(local)\SQLEXPRESS;
```

**SQL Server (full):**
```
data source=localhost;
```

**Named instance:**
```
data source=YOUR_PC_NAME\INSTANCE_NAME;
```

**SQL Authentication:**
```
data source=localhost;user id=sa;password=YourPassword;
```

---

## Verify Deployment

After setup, test these:

```sql
-- Check database exists
SELECT name FROM sys.databases WHERE name = 'Banking_Details';

-- Check all tables exist
SELECT COUNT(*) FROM sys.tables;  -- Should be 9+

-- Check admin account
SELECT * FROM UserLogin WHERE UserName = 'admin';

-- Check FD maturity amounts
SELECT COUNT(*) FROM FixedDepositAccount WHERE MaturityAmount IS NULL;
-- Should be 0
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't connect to SQL | Check SQL Server service is running |
| Build errors | Restore NuGet packages |
| EF errors | Update Model1.edmx from database |
| Login fails | Check admin account exists in UserLogin |

---

**Total Time:** 5 minutes  
**Difficulty:** Easy ?  
**Requirements:** USB drive or network share for files

**Happy Deploying!** ??

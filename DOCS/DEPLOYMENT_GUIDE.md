# ?? Deployment Guide - Moving Project to Another System

## Overview
This guide shows you how to deploy your Banking Application to a **different computer/system** while preserving all database changes.

---

## ?? Choose Your Deployment Method

| Method | Best For | Difficulty | Time |
|--------|----------|------------|------|
| **Option 1: Backup/Restore** | Another dev machine, local test | ? Easy | 10 min |
| **Option 2: Migration Scripts** | Production, team sharing | ?? Medium | 15 min |
| **Option 3: Git + Scripts** | Version control workflow | ??? Advanced | 20 min |

---

## ?? Option 1: Database Backup/Restore (Recommended for Dev)

### **On Source Machine (Your Current System)**

#### Step 1: Create Database Backup

1. Open **SQL Server Management Studio (SSMS)**
2. Connect to your SQL Server
3. Run this script:

```sql
USE master;
GO

-- Create backup directory if needed
EXEC xp_create_subdir 'D:\Database_Backups';
GO

-- Backup database
BACKUP DATABASE Banking_Details
TO DISK = 'D:\Database_Backups\Banking_Details_Complete.bak'
WITH FORMAT, 
     MEDIANAME = 'Banking_App_Backup',
     NAME = 'Full Backup with All Fixes',
     DESCRIPTION = 'Includes MaturityAmount fix, FD_MATURITY type, approval columns';
GO

PRINT '? Backup created: D:\Database_Backups\Banking_Details_Complete.bak';
GO
```

#### Step 2: Copy Files

**Copy these to USB/Cloud/Network:**

1. **Database Backup:**
   - `D:\Database_Backups\Banking_Details_Complete.bak`

2. **Project Files:**
   - Entire folder: `D:\CodeName_America\`

3. **Optional - SQL Scripts Folder:**
   - `D:\CodeName_America\SQL_Scripts\` (for reference)

---

### **On Target Machine (New System)**

#### Step 1: Install Prerequisites

1. **Install SQL Server:**
   - Download: [SQL Server 2019 Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- Or SQL Server Developer Edition (free)
   - Install with **Mixed Mode authentication** (optional)

2. **Install SQL Server Management Studio (SSMS):**
   - Download: [SSMS Latest](https://aka.ms/ssmsfullsetup)

3. **Install Visual Studio 2019/2022:**
   - Download: [Visual Studio Community](https://visualstudio.microsoft.com/downloads/)
   - Select workload: **ASP.NET and web development**

#### Step 2: Restore Database

1. Copy `Banking_Details_Complete.bak` to new machine (e.g., `C:\Temp\`)

2. Open **SSMS** on new machine

3. Connect to your SQL Server instance

4. Run this script:

```sql
USE master;
GO

-- Restore database
RESTORE DATABASE Banking_Details
FROM DISK = 'C:\Temp\Banking_Details_Complete.bak'
WITH REPLACE,
     MOVE 'Banking_Details' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Banking_Details.mdf',
     MOVE 'Banking_Details_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\Banking_Details_log.ldf',
     RECOVERY;
GO

PRINT '? Database restored successfully!';

-- Verify restore
SELECT 
    name AS 'Database',
    state_desc AS 'Status',
    compatibility_level AS 'Compatibility'
FROM sys.databases
WHERE name = 'Banking_Details';
GO
```

**Note:** Adjust paths if your SQL Server is installed elsewhere.

#### Step 3: Update Connection String

1. Copy project folder to new machine (e.g., `D:\CodeName_America\`)

2. Open solution in Visual Studio

3. Update connection string in **`Bank_App\Web.config`**:

```xml
<connectionStrings>
  <add name="Banking_DetailsEntities" 
       connectionString="metadata=res://*/Model1.csdl|res://*/Model1.ssdl|res://*/Model1.msl;
    provider=System.Data.SqlClient;
       provider connection string=&quot;
data source=(local)\SQLEXPRESS;
       initial catalog=Banking_Details;
       integrated security=True;
       MultipleActiveResultSets=True;
       App=EntityFramework&quot;" 
    providerName="System.Data.EntityClient" />
</connectionStrings>
```

**Replace `(local)\SQLEXPRESS` with:**
- `localhost` (if using full SQL Server)
- `YOUR_COMPUTER_NAME\SQLEXPRESS` (if different instance)
- `(local)` (if default instance)

4. Also update `BankApp.Services\App.config` and `DB\App.Config` with same connection string

#### Step 4: Build and Run

1. **Restore NuGet Packages:**
   ```
   Tools ? NuGet Package Manager ? Package Manager Console
   Update-Package -reinstall
   ```

2. **Build Solution:**
   ```
   Build ? Rebuild Solution (Ctrl + Shift + B)
   ```

3. **Run Application:**
   ```
   Debug ? Start Debugging (F5)
   ```

4. **Test Login:**
   - Username: `admin`
   - Password: `Dummy`

? **Done!** Your application with all database changes is now running on the new system.

---

## ?? Option 2: Migration Scripts (Professional Approach)

**Use this if:**
- You want version control of database changes
- Deploying to production
- Sharing with team members
- Fresh database install

### On Target Machine

#### Step 1: Create Fresh Database

```sql
-- In SSMS on new machine
CREATE DATABASE Banking_Details;
GO

USE Banking_Details;
GO

-- Run your original database creation script
-- (Create all tables, relationships, etc.)
```

#### Step 2: Apply Migration Script

Run the master migration script I created:

**File:** `SQL_Scripts/MASTER_MIGRATION_SCRIPT.sql`

```sql
-- This script includes ALL fixes:
-- ? Approval workflow columns
-- ? MaturityAmount precision fix
-- ? FD_MATURITY transaction type
-- ? Balance column
-- ? Recalculate maturity amounts
```

Open the file in SSMS and execute.

#### Step 3: Seed Initial Data (Optional)

```sql
-- Create default manager account
INSERT INTO Manager (ManagerId, ManagerName, Pan)
VALUES ('MGR001', 'Admin Manager', 'ADMIN12345');

INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID)
VALUES ('USER0001', 'admin', 'Dummy', 'MANAGER', 'MGR001');
GO

PRINT '? Created default admin account';
PRINT 'Username: admin';
PRINT 'Password: Dummy';
GO
```

#### Step 4: Update Project Files

Same as Option 1 - Steps 3-4 (update connection strings, build, run)

---

## ?? Option 3: Git + Migration Scripts (Team Workflow)

**Use this if:**
- Working in a team
- Using version control (Git/GitHub)
- Want reproducible deployments

### Setup Git Repository

Your project is already on GitHub: `https://github.com/MrFranklink/CodeName_America`

#### On New Machine:

1. **Clone Repository:**
   ```bash
   cd D:\
   git clone https://github.com/MrFranklink/CodeName_America.git
   cd CodeName_America
   ```

2. **Create Local Database:**
   ```sql
   CREATE DATABASE Banking_Details;
   GO
   ```

3. **Run Migration Scripts in Order:**

   ```sql
   -- Run these in SSMS, in this order:
   
   -- 1. Base schema (from your original creation script)
   -- 2. MASTER_MIGRATION_SCRIPT.sql (all fixes)
   -- 3. Seed data (optional)
   ```

4. **Configure Connection String:**
   - Update `Web.config`, `App.config` files
   - **DON'T commit connection strings to Git!**
   - Use `appsettings.Development.json` pattern or .gitignore

5. **Build and Run:**
   ```
   - Restore NuGet packages
   - Build solution
   - Run (F5)
   ```

---

## ?? Deployment Checklist

Use this checklist for any deployment:

### Before Deployment

- [ ] Test application on source machine (all features working)
- [ ] Create database backup (.bak file)
- [ ] Copy all SQL migration scripts
- [ ] Document any manual configuration steps
- [ ] Export sample data (if needed)
- [ ] Note SQL Server version and edition
- [ ] List all NuGet packages and versions

### On Target Machine

- [ ] Install SQL Server (same or newer version)
- [ ] Install Visual Studio
- [ ] Install SSMS
- [ ] Copy project files
- [ ] Restore database OR run migration scripts
- [ ] Update all connection strings
- [ ] Update Entity Framework model (if needed)
- [ ] Restore NuGet packages
- [ ] Build solution (check for errors)
- [ ] Run application
- [ ] Test login
- [ ] Test key features (register, open account, deposit, etc.)
- [ ] Check all database changes are applied

### Verification Tests

Run these to verify deployment:

```sql
-- Test 1: Check approval columns exist
SELECT COUNT(*) AS 'Approval Columns'
FROM sys.columns
WHERE object_id = OBJECT_ID('Account')
    AND name IN ('OpenedBy', 'OpenedByRole', 'ApprovedBy', 'RejectionReason');
-- Should return: 4

-- Test 2: Check MaturityAmount precision
SELECT NUMERIC_PRECISION, NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount' AND COLUMN_NAME = 'MaturityAmount';
-- Should return: 28, 8

-- Test 3: Check FD maturity amounts calculated
SELECT COUNT(*) AS 'FDs with NULL maturity'
FROM FixedDepositAccount
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;
-- Should return: 0

-- Test 4: Check transaction types
SELECT cc.definition
FROM sys.check_constraints cc
INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
WHERE t.name = 'SavingsTransaction'
    AND cc.name = 'CK_SavingsTransaction_Transactiontype';
-- Should include: FD_MATURITY

-- Test 5: Check user accounts
SELECT UserID, UserName, Role FROM UserLogin;
-- Should show at least admin account
```

---

## ?? Security Considerations

### For Development Systems:
- ? Use Windows Authentication (Integrated Security)
- ? Keep default passwords (`Dummy`) only for testing
- ? Don't expose to internet

### For Production Systems:
- ?? Change all default passwords
- ?? Use strong SQL Server passwords
- ?? Enable SSL/TLS
- ?? Use proper password hashing (already using SHA256)
- ?? Configure firewall rules
- ?? Regular database backups
- ?? Use encrypted connection strings

---

## ?? Troubleshooting

### Issue 1: Can't Connect to Database

**Error:** `A network-related or instance-specific error...`

**Solutions:**
1. Check SQL Server service is running (services.msc)
2. Verify server name in connection string
3. Enable TCP/IP in SQL Server Configuration Manager
4. Check Windows Firewall (allow SQL Server)

### Issue 2: Entity Framework Errors

**Error:** `The entity type X is not part of the model...`

**Solution:**
1. Update EF model: Right-click `Model1.edmx` ? Update Model from Database
2. Refresh all tables
3. Save and rebuild

### Issue 3: Migration Script Fails

**Error:** `Object already exists...`

**Solution:**
- Migration script has IF EXISTS checks
- Safe to re-run
- Check which step failed and continue from there

### Issue 4: Build Errors

**Error:** `Could not find a part of the path...`

**Solution:**
1. Check all connection strings updated
2. Restore NuGet packages
3. Clean solution, then rebuild
4. Check .NET Framework 4.8 is installed

---

## ?? Files to Share/Backup

### Essential Files

**For Backup/Restore Method:**
- `Banking_Details_Complete.bak` (database backup)
- Entire `CodeName_America\` folder

**For Migration Method:**
- `SQL_Scripts/MASTER_MIGRATION_SCRIPT.sql`
- Original database creation script
- Seed data script (initial admin account)
- Project source code (`CodeName_America\` folder)

### Documentation Files

- `README.md` (project overview)
- `DOCS/` folder (all guides)
- `SQL_Scripts/` folder (all migration scripts)

---

## ?? Best Practices

1. **Always backup before deployment**
   - Test backup/restore process
   - Keep multiple backup versions

2. **Use migration scripts for production**
   - Version controlled
   - Repeatable
   - Testable

3. **Document database changes**
   - Keep changelog of all migrations
   - Add comments to scripts
   - Note dates and reasons for changes

4. **Test on staging environment first**
   - Before production deployment
   - Test all user scenarios
   - Verify data integrity

5. **Version control**
   - Git for source code
   - SQL scripts in repository
   - .gitignore connection strings and secrets

---

## ?? Summary Comparison

| Aspect | Backup/Restore | Migration Scripts |
|--------|----------------|-------------------|
| **Speed** | ? Fast (10 min) | ?? Slower (15-20 min) |
| **Data** | ? Includes all data | ? Empty database |
| **Version Control** | ? Binary file | ? Text-based scripts |
| **Team Sharing** | ? Large files | ? Easy to share |
| **Production Ready** | ? Dev only | ? Yes |
| **Repeatable** | ?? One-time | ? Anytime |
| **Best For** | Dev machine copy | Production/Team |

---

## ? Quick Start Commands

### For Backup Method:
```sql
-- Source machine: Create backup
BACKUP DATABASE Banking_Details
TO DISK = 'D:\Banking_Details.bak'
WITH FORMAT;

-- Target machine: Restore
RESTORE DATABASE Banking_Details
FROM DISK = 'C:\Temp\Banking_Details.bak'
WITH REPLACE;
```

### For Migration Method:
```sql
-- Target machine: Run migration
:r D:\CodeName_America\SQL_Scripts\MASTER_MIGRATION_SCRIPT.sql
```

---

## ?? Need Help?

**Common Questions:**

**Q: Can I use SQL Server 2022 if source was 2019?**
A: Yes, backward compatible. Can't go backwards (2022 ? 2019).

**Q: Do I need same Visual Studio version?**
A: No, any VS 2019/2022 works for .NET Framework 4.8 projects.

**Q: Can I deploy to Linux?**
A: SQL Server yes (SQL Server for Linux), but ASP.NET MVC/.NET Framework needs Windows. Consider migrating to .NET Core for Linux.

**Q: How do I automate deployments?**
A: Use migration scripts + CI/CD tools (Azure DevOps, GitHub Actions).

---

**Created:** December 2024  
**Project:** Banking Application  
**Target:** Development System Deployment

? **Ready to deploy your project to any system!**

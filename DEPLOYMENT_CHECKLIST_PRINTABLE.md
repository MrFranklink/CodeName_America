# ? DEPLOYMENT CHECKLIST - Print This Page

## Banking Application - Quick Deployment Guide

---

### ?? PRE-DEPLOYMENT

**On Target System, Install:**
- [ ] SQL Server 2019+ (Express or Developer)
- [ ] SQL Server Management Studio (SSMS)
- [ ] Visual Studio 2019/2022
- [ ] .NET Framework 4.8

---

### ??? DATABASE SETUP (5 minutes)

**Open SSMS on target system:**

- [ ] **Step 1:** Run `MASTER_MIGRATION_SCRIPT.sql`
  - Creates database
  - Adds all columns
  - Fixes MaturityAmount precision
  - Recalculates FD amounts
  - **Expected:** "Migration Complete" message

- [ ] **Step 2:** Run `CREATE_ADMIN_ACCOUNT.sql`
  - Creates admin login
  - **Expected:** Username: admin, Password: Dummy

- [ ] **Step 3:** Run `VERIFY_DEPLOYMENT.sql`
  - Checks all changes applied
  - **Expected:** "All Checks Passed ?"

---

### ?? PROJECT SETUP (5 minutes)

**Copy project folder to target system:**
- [ ] Project copied to: `C:\Projects\CodeName_America\` (or your path)

**Update Connection Strings (3 files):**
- [ ] `Bank_App\Web.config`
- [ ] `BankApp.Services\App.config`
- [ ] `DB\App.config`

**Find this line in each file:**
```xml
data source=YOUR_OLD_SERVER;
```

**Replace with (SQL Express):**
```xml
data source=(local)\SQLEXPRESS;
```

**Or (Full SQL Server):**
```xml
data source=localhost;
```

---

### ?? BUILD & RUN (2 minutes)

**In Visual Studio:**
- [ ] Open solution file
- [ ] Tools ? NuGet Package Manager ? Package Manager Console
- [ ] Run: `Update-Package -reinstall`
- [ ] Build ? Rebuild Solution (Ctrl + Shift + B)
- [ ] **Expected:** 0 errors
- [ ] Press F5 to run

---

### ?? TESTING (3 minutes)

**Test Login:**
- [ ] Navigate to login page
- [ ] Username: `admin`
- [ ] Password: `Dummy`
- [ ] **Expected:** Redirect to Manager Dashboard

**Test Core Features:**
- [ ] Register Customer
  - **Expected:** Customer ID generated (MLA00001)
- [ ] Open Savings Account
  - **Expected:** Account created (SB00001)
- [ ] Make Deposit
  - **Expected:** Balance updated
- [ ] Check FD Balance
  - **Expected:** Shows maturity amount (NOT ?0.00)

---

### ? VERIFICATION

**Run these SQL queries to verify:**

```sql
-- 1. Check database exists
SELECT name FROM sys.databases WHERE name = 'Banking_Details';
-- Expected: 1 row

-- 2. Check admin account
SELECT * FROM UserLogin WHERE UserName = 'admin';
-- Expected: 1 row

-- 3. Check approval columns
SELECT COUNT(*) FROM sys.columns 
WHERE object_id = OBJECT_ID('Account')
AND name IN ('OpenedBy', 'OpenedByRole', 'ApprovedBy', 'RejectionReason');
-- Expected: 4

-- 4. Check FD maturity amounts
SELECT COUNT(*) FROM FixedDepositAccount 
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;
-- Expected: 0

-- 5. Check MaturityAmount precision
SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount' AND COLUMN_NAME = 'MaturityAmount';
-- Expected: 28
```

---

### ?? TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| **Can't connect to SQL Server** | Check SQL Server service is running (`services.msc`) |
| **Build errors** | Make sure NuGet packages restored |
| **Connection string error** | Verify server name: Run `SELECT @@SERVERNAME` in SSMS |
| **Login fails** | Check admin account created (Script 2) |
| **FD shows ?0.00** | Re-run migration script (safe to repeat) |
| **Entity Framework errors** | Right-click Model1.edmx ? Update from Database |

---

### ?? QUICK COMMANDS

**Find SQL Server Name:**
```sql
SELECT @@SERVERNAME;
```

**List all databases:**
```sql
SELECT name FROM sys.databases;
```

**Check SQL Server version:**
```sql
SELECT @@VERSION;
```

**Restore NuGet packages:**
```powershell
Update-Package -reinstall
```

---

### ?? SUCCESS CRITERIA

**Deployment is successful when:**
- ? All checkboxes above are checked
- ? Application runs without errors
- ? Can login as admin
- ? Can perform core operations
- ? FD shows maturity amounts
- ? No build errors

---

### ?? ESTIMATED TIME

| Task | Time |
|------|------|
| Prerequisites Install | 15-30 min (one-time) |
| Database Setup | 5 min |
| Project Setup | 5 min |
| Testing | 3 min |
| **Total** | **~45 min (or 13 min if prereqs installed)** |

---

### ?? NOTES

**Server Name Examples:**
- `(local)\SQLEXPRESS` - SQL Server Express
- `localhost` - Full SQL Server default instance
- `YOUR_PC_NAME\INSTANCE_NAME` - Named instance
- `192.168.1.100` - Remote server (IP address)

**Connection String Location:**
Find in 3 files - look for `<connectionStrings>` section

**Default Credentials:**
- Username: `admin`
- Password: `Dummy`
- ?? **Change in production!**

---

### ?? POST-DEPLOYMENT SECURITY

**After successful deployment:**
- [ ] Change admin password from `Dummy`
- [ ] Create additional manager accounts
- [ ] Review user permissions
- [ ] Enable SQL Server authentication (optional)
- [ ] Configure firewall rules
- [ ] Set up regular backups

---

### ?? FILES TO CARRY

**Essential:**
- ? This checklist
- ? 3 SQL scripts
- ? Connection string templates
- ? Project source code

**Optional:**
- Database backup (.bak file)
- Full documentation folder
- Sample data scripts

---

**? DEPLOYMENT COMPLETE! ?**

**Next Steps:**
1. Test all features
2. Change default passwords
3. Create backups
4. Document any customizations

---

*Print this page and keep with deployment package*  
*Version: 1.0 | December 2024*

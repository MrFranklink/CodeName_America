# ?? PORTABLE DEPLOYMENT PACKAGE - Banking Application

## ?? **Carry This Package With You**

This is your **complete, portable deployment package**. Copy this to USB/Cloud and you can deploy the Banking Application on **any system**.

---

## ?? **Package Structure**

```
PORTABLE_PACKAGE/
?
??? ?? THIS_README.md      ? You are here
?
??? ?? 1_SQL_SCRIPTS/               ? Run these in SSMS
?   ??? STEP_1_MIGRATION.sql  ? Apply all database changes
?   ??? STEP_2_ADMIN_ACCOUNT.sql   ? Create login (admin/Dummy)
?   ??? STEP_3_VERIFY.sql          ? Check everything worked
?
??? ?? 2_CONNECTION_STRINGS/        ? Copy-paste templates
?   ??? ALL_CONNECTION_TEMPLATES.txt
?
??? ?? 3_PROJECT_SOURCE/      ? Your Visual Studio solution
    ??? (Copy entire CodeName_America folder here)
```

---

## ?? **5-MINUTE DEPLOYMENT GUIDE**

### **What You Need on Target System:**
1. SQL Server 2019+ (Express is free)
2. Visual Studio 2019/2022 (Community is free)
3. SSMS (SQL Server Management Studio)

---

### **Step 1: Database Setup (2 minutes)**

Open **SQL Server Management Studio** on new system:

1. **Connect to SQL Server**
2. **Run Script 1** (in order):

```sql
-- File: 1_SQL_SCRIPTS/STEP_1_MIGRATION.sql
-- This creates database and applies all fixes
-- Copy-paste entire script and execute
```

3. **Run Script 2**:

```sql
-- File: 1_SQL_SCRIPTS/STEP_2_ADMIN_ACCOUNT.sql
-- Creates admin login
```

4. **Run Script 3** (verification):

```sql
-- File: 1_SQL_SCRIPTS/STEP_3_VERIFY.sql
-- Checks everything is correct
```

---

### **Step 2: Project Setup (3 minutes)**

1. **Copy project folder** from package to new system  
   (e.g., `C:\Projects\CodeName_America\`)

2. **Update 3 connection strings**:

   Open these files and update `data source`:

   ?? **File 1:** `Bank_App\Web.config`
   ```xml
<connectionStrings>
     <add name="Banking_DetailsEntities" 
    connectionString="metadata=res://*/Model1.csdl|res://*/Model1.ssdl|res://*/Model1.msl;
          provider=System.Data.SqlClient;
          provider connection string=&quot;
          data source=(local)\SQLEXPRESS;   ? CHANGE THIS
    initial catalog=Banking_Details;
          integrated security=True;
  MultipleActiveResultSets=True;
          App=EntityFramework&quot;" 
providerName="System.Data.EntityClient" />
   </connectionStrings>
   ```

   ?? **File 2:** `BankApp.Services\App.config`  
   ?? **File 3:** `DB\App.config`

   *Use templates from `2_CONNECTION_STRINGS/ALL_CONNECTION_TEMPLATES.txt`*

3. **Open solution in Visual Studio**

4. **Restore NuGet packages**:
   ```
   Tools ? NuGet Package Manager ? Package Manager Console
   Update-Package -reinstall
   ```

5. **Build solution**:
   ```
   Build ? Rebuild Solution (Ctrl + Shift + B)
   ```

6. **Run application** (F5)

7. **Test login**:
   - Username: `admin`
   - Password: `Dummy`

? **DONE! Application is running!**

---

## ?? **COMPLETE SQL SCRIPTS (Copy-Paste Ready)**

### **SCRIPT 1: MASTER MIGRATION (All Changes)**

```sql
-- ========================================
-- MASTER MIGRATION SCRIPT
-- Banking Application - All Database Changes
-- ========================================

USE master;
GO

-- Create database if not exists
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Banking_Details')
BEGIN
    CREATE DATABASE Banking_Details;
    PRINT '? Created Banking_Details database';
END
ELSE
 PRINT '??  Database already exists';
GO

USE Banking_Details;
GO

PRINT '????????????????????????????????????????????????????????????????????';
PRINT '?  BANKING APP - DATABASE MIGRATION SCRIPT    ?';
PRINT '?  Version: 1.0 - December 2024       ?';
PRINT '????????????????????????????????????????????????????????????????????';
PRINT '';

-- STEP 1: Add Approval Workflow Columns
PRINT 'STEP 1: Adding approval workflow columns...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'OpenedBy')
BEGIN
    ALTER TABLE Account ADD OpenedBy VARCHAR(20) NULL;
    PRINT '  ? Added OpenedBy column';
END
ELSE
    PRINT '  ??  OpenedBy already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'OpenedByRole')
BEGIN
    ALTER TABLE Account ADD OpenedByRole VARCHAR(20) NULL;
    PRINT '  ? Added OpenedByRole column';
END
ELSE
    PRINT '  ??  OpenedByRole already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'ApprovedBy')
BEGIN
    ALTER TABLE Account ADD ApprovedBy VARCHAR(20) NULL;
    PRINT '  ? Added ApprovedBy column';
END
ELSE
    PRINT '  ??ApprovedBy already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'RejectionReason')
BEGIN
    ALTER TABLE Account ADD RejectionReason VARCHAR(500) NULL;
    PRINT '  ? Added RejectionReason column';
END
ELSE
    PRINT '  ??  RejectionReason already exists';

PRINT '';

-- STEP 2: Fix MaturityAmount Precision
PRINT 'STEP 2: Fixing FixedDepositAccount MaturityAmount precision...';

DECLARE @CurrentPrecision INT;
SELECT @CurrentPrecision = NUMERIC_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount' AND COLUMN_NAME = 'MaturityAmount';

IF @CurrentPrecision < 28
BEGIN
 ALTER TABLE FixedDepositAccount ALTER COLUMN MaturityAmount DECIMAL(28,8) NULL;
    PRINT '  ? Increased precision to DECIMAL(28,8)';
END
ELSE
    PRINT '  ??  Precision already correct';

PRINT '';

-- STEP 3: Ensure Balance Column
PRINT 'STEP 3: Ensuring SavingsAccount Balance column...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SavingsAccount') AND name = 'Balance')
BEGIN
    ALTER TABLE SavingsAccount ADD Balance DECIMAL(18,2) NULL;
    PRINT '  ? Added Balance column';
    
    UPDATE sa
    SET Balance = (
      SELECT ISNULL(SUM(
            CASE 
       WHEN st.Transactiontype IN ('DEPOSIT', 'INITIAL DEPOSIT', 'TRANSFER_CREDIT', 'FD_MATURITY') THEN st.Amount
       WHEN st.Transactiontype IN ('WITHDRAW', 'WITHDRAWAL', 'TRANSFER_DEBIT', 'LOAN_PAYMENT') THEN -st.Amount
 ELSE 0
   END
     ), 0)
 FROM SavingsTransaction st
        WHERE st.SBAccountID = sa.SBAccountID
    )
    FROM SavingsAccount sa;
    
    PRINT '  ? Calculated balances';
END
ELSE
    PRINT '  ??  Balance column exists';

PRINT '';

-- STEP 4: Add FD_MATURITY Transaction Type
PRINT 'STEP 4: Adding FD_MATURITY transaction type...';

IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_SavingsTransaction_Transactiontype')
BEGIN
    ALTER TABLE SavingsTransaction DROP CONSTRAINT CK_SavingsTransaction_Transactiontype;
END

ALTER TABLE SavingsTransaction
ADD CONSTRAINT CK_SavingsTransaction_Transactiontype
CHECK (Transactiontype IN (
'DEPOSIT', 'WITHDRAW', 'WITHDRAWAL', 'INITIAL DEPOSIT',
  'TRANSFER_DEBIT', 'TRANSFER_CREDIT', 'LOAN_PAYMENT', 'FD_MATURITY'
));

PRINT '  ? Added FD_MATURITY type';
PRINT '';

-- STEP 5: Recalculate FD Maturity Amounts
PRINT 'STEP 5: Recalculating FD maturity amounts...';

DECLARE @UpdatedCount INT;

UPDATE fd
SET MaturityAmount = 
    CAST(
        fd.Amount * 
        POWER(
      CAST((1 + fd.FD_ROI / 100.0) AS FLOAT), 
    CAST(DATEDIFF(MONTH, fd.StartDate, fd.EndDate) / 12.0 AS FLOAT)
        )
        AS DECIMAL(28,8)
)
FROM FixedDepositAccount fd
WHERE (fd.MaturityAmount IS NULL OR fd.MaturityAmount = 0)
    AND fd.Amount IS NOT NULL AND fd.Amount > 0;

SET @UpdatedCount = @@ROWCOUNT;
PRINT '  ? Recalculated ' + CAST(@UpdatedCount AS VARCHAR) + ' FD accounts';
PRINT '';

-- STEP 6: Verification
PRINT '????????????????????????????????????????????????????????????????????';
PRINT '?  MIGRATION COMPLETE!          ?';
PRINT '????????????????????????????????????????????????????????????????????';
PRINT '';
PRINT '? All database changes applied successfully!';
PRINT '';
GO
```

---

### **SCRIPT 2: CREATE ADMIN ACCOUNT**

```sql
USE Banking_Details;
GO

PRINT 'Creating default admin account...';

-- Create manager
IF NOT EXISTS (SELECT * FROM Manager WHERE ManagerId = 'MGR001')
BEGIN
    INSERT INTO Manager (ManagerId, ManagerName, Pan)
VALUES ('MGR001', 'System Administrator', 'ADMIN12345');
    PRINT '? Created Manager account';
END

-- Create login
IF NOT EXISTS (SELECT * FROM UserLogin WHERE UserName = 'admin')
BEGIN
    INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID)
    VALUES ('USER0001', 'admin', 'Dummy', 'MANAGER', 'MGR001');
    PRINT '? Created Login account';
    PRINT '';
    PRINT '???????????????????????????????????????';
    PRINT '  DEFAULT LOGIN CREDENTIALS:';
    PRINT '  Username: admin';
  PRINT '  Password: Dummy';
    PRINT '???????????????????????????????????????';
END
ELSE
    PRINT '??  Admin account already exists';

GO
```

---

### **SCRIPT 3: VERIFY DEPLOYMENT**

```sql
USE Banking_Details;
GO

PRINT '????????????????????????????????????????????????????????????????????';
PRINT '?  DEPLOYMENT VERIFICATION ?';
PRINT '????????????????????????????????????????????????????????????????????';
PRINT '';

-- Check approval columns
DECLARE @ApprovalCols INT;
SELECT @ApprovalCols = COUNT(*)
FROM sys.columns
WHERE object_id = OBJECT_ID('Account')
    AND name IN ('OpenedBy', 'OpenedByRole', 'ApprovedBy', 'RejectionReason');

PRINT 'Approval Columns: ' + CAST(@ApprovalCols AS VARCHAR) + '/4 ' + 
      CASE WHEN @ApprovalCols = 4 THEN '?' ELSE '?' END;

-- Check MaturityAmount precision
DECLARE @Precision INT;
SELECT @Precision = NUMERIC_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount' AND COLUMN_NAME = 'MaturityAmount';

PRINT 'MaturityAmount Precision: ' + CAST(@Precision AS VARCHAR) + ' ' +
      CASE WHEN @Precision = 28 THEN '?' ELSE '?' END;

-- Check FD maturity amounts
DECLARE @NullFDs INT;
SELECT @NullFDs = COUNT(*)
FROM FixedDepositAccount
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;

PRINT 'FDs with NULL maturity: ' + CAST(@NullFDs AS VARCHAR) + ' ' +
  CASE WHEN @NullFDs = 0 THEN '?' ELSE '??' END;

-- Check admin account
DECLARE @AdminExists INT;
SELECT @AdminExists = COUNT(*)
FROM UserLogin
WHERE UserName = 'admin';

PRINT 'Admin account exists: ' + CASE WHEN @AdminExists > 0 THEN 'YES ?' ELSE 'NO ?' END;

PRINT '';

IF @ApprovalCols = 4 AND @Precision = 28 AND @AdminExists > 0
BEGIN
    PRINT '????????????????????????????????????????????????????????????????????';
    PRINT '?  ? ALL CHECKS PASSED - DEPLOYMENT SUCCESSFUL!       ?';
  PRINT '????????????????????????????????????????????????????????????????????';
END
ELSE
BEGIN
    PRINT '????????????????????????????????????????????????????????????????????';
    PRINT '?  ??  SOME CHECKS FAILED - REVIEW ERRORS ABOVE       ?';
    PRINT '????????????????????????????????????????????????????????????????????';
END

PRINT '';
GO
```

---

## ?? **CONNECTION STRING TEMPLATES**

### **Template 1: SQL Server Express (Most Common)**

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

### **Template 2: SQL Server (Full Version)**

```xml
data source=localhost;
initial catalog=Banking_Details;
integrated security=True;
```

### **Template 3: SQL Server with Authentication**

```xml
data source=localhost;
initial catalog=Banking_Details;
user id=sa;
password=YourPassword;
integrated security=False;
```

---

## ? **POST-DEPLOYMENT CHECKLIST**

- [ ] Database created
- [ ] Migration script ran successfully
- [ ] Admin account created
- [ ] All 3 connection strings updated
- [ ] NuGet packages restored
- [ ] Solution builds without errors
- [ ] Login works (admin/Dummy)
- [ ] Can register customer
- [ ] Can open account
- [ ] Can make deposit
- [ ] FD shows maturity amount (not ?0.00)

---

## ?? **WHAT TO COPY TO USB/CLOUD**

**Minimum Files (for migration only):**
- ? This README file
- ? 3 SQL scripts (above)
- ? Connection string templates (above)
- ? Your project source code folder

**Complete Package:**
- ? Everything above
- ? Database backup file (optional, for data migration)
- ? All documentation from `DOCS/` folder

---

## ?? **QUICK REFERENCE CARD**

| Task | Command/Location |
|------|------------------|
| **Find SQL Server Name** | In SSMS: `SELECT @@SERVERNAME` |
| **Test Connection** | SSMS ? Connect to Server |
| **Restore NuGet** | `Update-Package -reinstall` |
| **Build Solution** | `Ctrl + Shift + B` |
| **Run App** | `F5` |
| **Default Login** | admin / Dummy |

---

## ?? **TROUBLESHOOTING**

| Problem | Solution |
|---------|----------|
| **Can't find SQL Server** | Check service running: `services.msc` ? SQL Server |
| **Connection fails** | Update connection string with correct server name |
| **Build errors** | Restore NuGet packages first |
| **EF errors** | Update Model1.edmx from database |
| **FD shows ?0.00** | Re-run Script 1 (safe to run multiple times) |
| **Can't login** | Check Script 2 ran successfully |

---

## ?? **SUPPORT**

- **GitHub:** https://github.com/MrFranklink/CodeName_America
- **Issues:** Create issue on GitHub
- **Documentation:** Check `DOCS/` folder in project

---

## ?? **VERSION INFO**

- **Package Version:** 1.0
- **Created:** December 2024
- **Compatible With:**
  - SQL Server 2019+
  - .NET Framework 4.8
  - Visual Studio 2019/2022

---

## ?? **PRO TIPS**

1. **Test on VM first** before production
2. **Keep backup** of original database
3. **Update passwords** from default (`Dummy`)
4. **Scripts are idempotent** - safe to re-run
5. **Check verification script** after each deployment

---

**?? READY TO DEPLOY! Everything you need is in this file.**

**Total Deployment Time: 5-10 minutes**  
**Difficulty: Easy ?**

---

*Last Updated: December 2024*  
*Project: Banking Application - ASP.NET MVC*  
*Author: https://github.com/MrFranklink*

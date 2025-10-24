# ?? ONE-PAGE DEPLOYMENT CARD

## Banking Application - Deploy in 10 Minutes

---

## ?? WHAT YOU NEED
- USB/Cloud with project files
- SQL Server 2019+
- Visual Studio 2019+
- SSMS

---

## ? 3-STEP DEPLOYMENT

### **1?? DATABASE (3 min)**

**Open SSMS, run 3 scripts in order:**

```sql
-- Script 1: Migration (creates/updates database)
:r C:\path\to\MASTER_MIGRATION_SCRIPT.sql

-- Script 2: Admin account (creates login)
:r C:\path\to\CREATE_ADMIN_ACCOUNT.sql

-- Script 3: Verify (checks success)
:r C:\path\to\VERIFY_DEPLOYMENT.sql
```

**Expected output:** "Migration Complete ?"

---

### **2?? CONNECTION STRINGS (2 min)**

**Update in 3 files:**
- `Bank_App\Web.config`
- `BankApp.Services\App.config`
- `DB\App.config`

**Find:**
```xml
data source=OLD_SERVER;
```

**Replace with:**
```xml
data source=(local)\SQLEXPRESS;
```

---

### **3?? BUILD & RUN (5 min)**

**In Visual Studio:**
1. Open solution
2. Restore NuGet: `Update-Package -reinstall`
3. Build: `Ctrl + Shift + B`
4. Run: `F5`
5. Login: `admin` / `Dummy`

? **DONE!**

---

## ?? QUICK TESTS

```sql
-- Test 1: Database exists?
SELECT name FROM sys.databases WHERE name = 'Banking_Details';

-- Test 2: Admin exists?
SELECT * FROM UserLogin WHERE UserName = 'admin';

-- Test 3: Columns added?
SELECT COUNT(*) FROM sys.columns 
WHERE object_id = OBJECT_ID('Account')
AND name IN ('OpenedBy', 'OpenedByRole', 'ApprovedBy', 'RejectionReason');
-- Should return: 4

-- Test 4: FD amounts calculated?
SELECT COUNT(*) FROM FixedDepositAccount 
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;
-- Should return: 0
```

---

## ?? COMMON FIXES

| Problem | Fix |
|---------|-----|
| Can't connect SQL | `services.msc` ? Start SQL Server |
| Build errors | Restore NuGet first |
| Connection fails | Check server name: `SELECT @@SERVERNAME` |
| Login fails | Re-run script 2 |
| FD shows ?0.00 | Re-run script 1 |

---

## ?? CONNECTION STRING TEMPLATES

**SQL Express:**
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

**Full SQL Server:**
Change `data source` to: `localhost`

**SQL Auth:**
Add: `user id=sa;password=YourPass;integrated security=False;`

---

## ? SUCCESS CHECKLIST

- [ ] All 3 scripts ran without errors
- [ ] Connection strings updated (3 files)
- [ ] NuGet restored
- [ ] Solution builds (0 errors)
- [ ] App runs (F5 works)
- [ ] Can login (admin/Dummy)
- [ ] Can register customer
- [ ] Can open account
- [ ] FD shows maturity (not ?0.00)

---

## ?? CORE FILES NEEDED

**From USB/Cloud:**
1. `MASTER_MIGRATION_SCRIPT.sql`
2. `CREATE_ADMIN_ACCOUNT.sql`
3. `VERIFY_DEPLOYMENT.sql`
4. Project folder (CodeName_America)
5. This card

**That's it!** Everything else is generated.

---

## ?? TIME BREAKDOWN

| Step | Time |
|------|------|
| Database scripts | 3 min |
| Update connections | 2 min |
| Build & run | 5 min |
| **Total** | **10 min** |

*(Assuming SQL Server already installed)*

---

## ?? EMERGENCY COMMANDS

**Find server name:**
```sql
SELECT @@SERVERNAME;
```

**Check database:**
```sql
SELECT DB_NAME();
```

**List tables:**
```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES;
```

**Force NuGet restore:**
```powershell
dotnet restore
```

---

## ?? DEFAULT CREDENTIALS

**Login:** `admin`  
**Password:** `Dummy`

?? **Change after first login!**

---

## ?? PACKAGE SUMMARY

**What's Included:**
? All database changes (approval, FD fixes, balance)  
? FD maturity calculation  
? Admin account creation  
? Verification script  
? Connection templates

**What's NOT Included:**
? Sample data (optional)  
? Database backup (create separately)  
? Custom configurations

---

## ?? PRO TIPS

1. **Test on VM first**
2. **Backup before migrating**
3. **Scripts are safe to re-run**
4. **Check verification script output**
5. **Update passwords after deployment**

---

## ?? WHAT GETS FIXED

| Feature | Status |
|---------|--------|
| Approval workflow | ? Added |
| FD maturity precision | ? Fixed (28,8) |
| Balance column | ? Added & calculated |
| FD_MATURITY type | ? Added |
| Maturity calculation | ? Auto-recalculated |

---

## ?? WORKS ON

- ? Windows 10/11
- ? Windows Server 2016+
- ? SQL Server 2019+
- ? SQL Server Express (free)
- ? Visual Studio Community (free)

---

**TOTAL DEPLOYMENT TIME: 10 MINUTES** ??

**PRINT THIS CARD** ???

---

*Keep with USB deployment package*  
*Version 1.0 | December 2024*  
*https://github.com/MrFranklink/CodeName_America*

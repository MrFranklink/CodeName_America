# ?? **Cleanup Workspace Script - User Guide**

---

## ?? **Overview**

The `Cleanup_Workspace.ps1` script safely removes unnecessary backup files and old documentation from your workspace while preserving all active/important files.

**Features:**
- ? Creates backup before deletion
- ? Dry-run mode to preview changes
- ? Optional deletion of diagnostic SQL and old docs
- ? Color-coded output
- ? Summary report

---

## ?? **Quick Start**

### **Step 1: Open PowerShell**

1. Press `Windows + X`
2. Select **"Windows PowerShell"** or **"Terminal"**
3. Navigate to your workspace:
   ```powershell
   cd C:\Users\harshit.kaundal2\source\repos\Bank_Destroyer
   ```

### **Step 2: Run the Script**

**Option 1: Preview what will be deleted (Dry Run)**
```powershell
.\Cleanup_Workspace.ps1 -DryRun
```
This shows what would be deleted **without actually deleting anything**.

**Option 2: Delete files with automatic backup**
```powershell
.\Cleanup_Workspace.ps1
```
This creates a backup and deletes the files.

**Option 3: Delete everything including diagnostic SQL**
```powershell
.\Cleanup_Workspace.ps1 -DeleteDiagnosticSQL
```

**Option 4: Delete everything including old docs**
```powershell
.\Cleanup_Workspace.ps1 -DeleteOldDocs
```

**Option 5: Delete ALL unnecessary files**
```powershell
.\Cleanup_Workspace.ps1 -DeleteDiagnosticSQL -DeleteOldDocs
```

---

## ??? **Execution Policy Error?**

If you get an error like:
```
cannot be loaded because running scripts is disabled on this system
```

**Fix it:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then run the script again.

---

## ?? **What Gets Deleted?**

### **Always Deleted (17 files):**
- ? 11 old view backups (`*_OLD*.cshtml`, `*_Modern.cshtml`, etc.)
- ? 4 Task 2 documentation files
- ? 2 Task 2 SQL scripts

### **Optional - Diagnostic SQL (8 files):**
Use `-DeleteDiagnosticSQL` to delete:
- `Check_Loan_Accounts_Status.sql`
- `Diagnose_*.sql`
- `Check_Employee_Constraints.sql`
- `Find_*.sql`
- `Verify_*.sql`

### **Optional - Old Docs (21 files):**
Use `-DeleteOldDocs` to delete:
- Old fix documentation
- Workspace cleanup summaries
- UI downgrade notes
- Error fix guides

---

## ?? **What's NEVER Deleted?**

### **Active Code:**
? `CustomerDashboard.cshtml`, `ManagerDashboard.cshtml`, `EmployeeDashboard.cshtml`  
? `DashboardController.cs`, `AuthController.cs`  
? All service files in `BankApp.Services`  
? All repository files in `DB`

### **Important Docs:**
? `README.md`  
? `PROJECT_SUMMARY.md`  
? `HANDOFF.md`  
? `PAN_Validation_Guide.md`  
? `Employee_Dashboard_Quick_Reference.md`  
? Password security guides

### **Active SQL Scripts:**
? `Fix_*.sql` files  
? `Update_*.sql` files  
? `Create_FundTransfer_Table.sql`  
? `Delete_All_Data.sql` (useful for testing)

### **Configuration:**
? `Web.config`  
? `App.config`  
? `packages.config`

---

## ?? **Usage Examples**

### **Example 1: Safe Preview (Recommended First Step)**
```powershell
.\Cleanup_Workspace.ps1 -DryRun
```

**Output:**
```
=============================================
   WORKSPACE CLEANUP SCRIPT
=============================================

Working Directory: C:\Users\harshit.kaundal2\source\repos\Bank_Destroyer

Deleting files...

[DRY RUN] Would delete: Bank_App\Views\Dashboard\CustomerDashboard_OLD_V2.cshtml
[DRY RUN] Would delete: DOCS\Task2_Progress_Report.md
...

=============================================
   CLEANUP SUMMARY
=============================================

[DRY RUN MODE - No files were actually deleted]

Files processed: 17
Files deleted:   17
Errors:          0
```

### **Example 2: Delete with Backup**
```powershell
.\Cleanup_Workspace.ps1
```

**Output:**
```
Creating backup...
? Backup created: BACKUP_20250116_143022

Deleting files...

? Deleted: Bank_App\Views\Dashboard\CustomerDashboard_OLD_V2.cshtml
? Deleted: DOCS\Task2_Progress_Report.md
...

Backup folder:   BACKUP_20250116_143022
```

### **Example 3: Maximum Cleanup**
```powershell
.\Cleanup_Workspace.ps1 -DeleteDiagnosticSQL -DeleteOldDocs
```

This deletes:
- 17 standard files
- 8 diagnostic SQL files
- 21 old documentation files
- **Total: 46 files**

---

## ?? **After Running the Script**

### **Step 1: Verify Build**
```powershell
dotnet build
```
or
```powershell
msbuild Bank_Destroyer.sln
```

### **Step 2: Test the Application**
1. Run the application (F5 in Visual Studio)
2. Test login
3. Test customer/manager/employee dashboards
4. Test key features (deposit, withdraw, transfer, pay EMI)

### **Step 3: If Everything Works**
Delete the backup folder:
```powershell
Remove-Item -Recurse -Force BACKUP_20250116_143022
```
(Replace with your actual backup folder name)

### **Step 4: Commit Changes (Optional)**
```powershell
git status
git add .
git commit -m "Cleanup: Removed old backup files and Task 2 remnants"
git push
```

---

## ?? **Troubleshooting**

### **Problem: Script won't run**
**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### **Problem: "Access Denied" error**
**Solution:** Run PowerShell as Administrator:
1. Right-click PowerShell
2. Select "Run as Administrator"
3. Navigate to workspace and run script

### **Problem: Files not found**
**Solution:** The script skips files that don't exist. This is normal if you've already deleted some files manually.

### **Problem: Need to restore deleted files**
**Solution:** Use the backup folder:
```powershell
# Copy all files back from backup
Copy-Item -Path "BACKUP_20250116_143022\*" -Destination ".\" -Recurse -Force
```

---

## ?? **Command Reference**

| Command | Description |
|---------|-------------|
| `.\Cleanup_Workspace.ps1` | Delete with backup |
| `.\Cleanup_Workspace.ps1 -DryRun` | Preview only, no deletion |
| `.\Cleanup_Workspace.ps1 -DeleteDiagnosticSQL` | Also delete diagnostic SQL files |
| `.\Cleanup_Workspace.ps1 -DeleteOldDocs` | Also delete old documentation |
| `.\Cleanup_Workspace.ps1 -DeleteDiagnosticSQL -DeleteOldDocs` | Maximum cleanup |

---

## ?? **Important Notes**

1. **Always run with `-DryRun` first** to see what will be deleted
2. **Backup is created automatically** (unless you use `-CreateBackup:$false`)
3. **Test the application** after cleanup before deleting the backup
4. **Keep important docs** like README.md, PROJECT_SUMMARY.md, HANDOFF.md
5. **Diagnostic SQL files** are safe to delete after issues are fixed

---

## ?? **Recommended Workflow**

```powershell
# Step 1: Preview
.\Cleanup_Workspace.ps1 -DryRun

# Step 2: Review the list, if satisfied, run actual cleanup
.\Cleanup_Workspace.ps1

# Step 3: Verify build
dotnet build

# Step 4: Test application
# (Run in Visual Studio, test features)

# Step 5: If all good, delete backup
Remove-Item -Recurse -Force BACKUP_20250116_143022

# Step 6: Optionally delete diagnostic SQL and old docs
.\Cleanup_Workspace.ps1 -DeleteDiagnosticSQL -DeleteOldDocs

# Step 7: Commit to Git
git add .
git commit -m "Workspace cleanup complete"
git push
```

---

## ?? **Need Help?**

If you encounter any issues:
1. Check the error message in red
2. Make sure you're in the correct directory
3. Verify execution policy is set correctly
4. Check that Visual Studio is closed (to avoid file locks)
5. Run PowerShell as Administrator if needed

---

**Happy Cleaning! ???**

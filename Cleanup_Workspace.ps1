# =============================================
# Workspace Cleanup Script
# =============================================
# This script removes unnecessary backup files and old documentation
# while preserving all active/important files
#
# IMPORTANT: This creates a backup before deletion!
# =============================================

param(
    [switch]$CreateBackup = $true,
    [switch]$DryRun = $false,
    [switch]$DeleteDiagnosticSQL = $false,
    [switch]$DeleteOldDocs = $false
)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   WORKSPACE CLEANUP SCRIPT" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Working Directory: $scriptPath" -ForegroundColor Yellow
Write-Host ""

# =============================================
# Configuration
# =============================================

$backupFolder = "BACKUP_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$deletedCount = 0
$errors = 0

# Files to delete
$filesToDelete = @(
    # Old View Backups
    "Bank_App\Views\Dashboard\ChangePassword_OLD_V2.cshtml",
    "Bank_App\Views\Dashboard\CustomerDashboard_OLD_BACKUP.cshtml",
    "Bank_App\Views\Dashboard\CustomerDashboard_OLD_V2.cshtml",
    "Bank_App\Views\Dashboard\CustomerDashboard_Modern.cshtml",
    "Bank_App\Views\Dashboard\CustomerDashboard_Enhanced.cshtml",
    "Bank_App\Views\Dashboard\EmployeeDashboard_OLD_V2.cshtml",
    "Bank_App\Views\Dashboard\ManagerDashboard_Old.cshtml",
    "Bank_App\Views\Dashboard\ManagerDashboard_OLD_V2.cshtml",
    "Bank_App\Views\Dashboard\ManagerDashboard_New.cshtml",
    "Bank_App\Views\Dashboard\_ManagerDashboardNewTabs.cshtml",
    "Bank_App\Views\Dashboard\ManagerDashboard_Modern_Part1.cshtml",
    
    # Task 2 Documentation
    "DOCS\Application_Approval_Workflow_Implementation.md",
    "DOCS\Task2_Progress_Report.md",
    "DOCS\Task2_Build_Error_Fix.md",
    "DOCS\Task2_Revert_Complete.md",
    
    # Task 2 SQL Scripts
    "SQL_Scripts\Create_Application_Tables.sql",
    "SQL_Scripts\Revert_Task2_Drop_Application_Tables.sql"
)

# Diagnostic SQL files (optional deletion)
$diagnosticSQLFiles = @(
    "SQL_Scripts\Check_Loan_Accounts_Status.sql",
    "SQL_Scripts\Diagnose_PAN_Column_Size.sql",
    "SQL_Scripts\Diagnose_Loan_Account_Error.sql",
    "SQL_Scripts\Check_Employee_Constraints.sql",
    "SQL_Scripts\Diagnose_Employee_Registration.sql",
    "SQL_Scripts\Find_Transactiontype_Check_Constraint.sql",
    "SQL_Scripts\Verify_Transaction_Types_Length.sql",
    "SQL_Scripts\Check_Transactiontype_Column_Size.sql"
)

# Old documentation files (optional deletion)
$oldDocFiles = @(
    "DOCS\Build_Fix_Temporary_Solution.md",
    "DOCS\Workspace_Cleanup_Summary.md",
    "DOCS\UI_Downgrade_Summary.md",
    "DOCS\Entity_Validation_Error_Fix.md",
    "DOCS\Employee_Registration_Error_Fix.md",
    "DOCS\Loan_Account_Error_Fix.md",
    "DOCS\Fix_Pan_Column_Size_VARCHAR10.md",
    "DOCS\PAN_Column_Resize_Fix.md",
    "DOCS\UserLogin_Fix_Summary.md",
    "DOCS\Constraint_Fix_Complete.md",
    "DOCS\Invalid_Date_Fix.md",
    "DOCS\Check_Constraint_Blocking_Transfers_Fix.md",
    "DOCS\Transactiontype_Column_Truncation_Fix.md",
    "DOCS\Transfer_Transaction_Display_Fix.md",
    "DOCS\Customer_Transaction_History_Fix.md",
    "DOCS\Transaction_Modal_Empty_Debug_Guide.md",
    "DOCS\UX_Fixes_Complete_Implementation.md",
    "DOCS\Auto_Open_Transaction_History_Implementation.md",
    "DOCS\Customer_Dashboard_Empty_State_Complete.md",
    "DOCS\Manager_Dashboard_Tab_Reorganization.md",
    "DOCS\Loan_EMI_Requirements_Match_Verification.md"
)

# Add optional files if switches are enabled
if ($DeleteDiagnosticSQL) {
    $filesToDelete += $diagnosticSQLFiles
    Write-Host "[OPTION] Diagnostic SQL files will be deleted" -ForegroundColor Yellow
}

if ($DeleteOldDocs) {
    $filesToDelete += $oldDocFiles
    Write-Host "[OPTION] Old documentation files will be deleted" -ForegroundColor Yellow
}

Write-Host ""

# =============================================
# Create Backup
# =============================================

if ($CreateBackup -and -not $DryRun) {
    Write-Host "Creating backup..." -ForegroundColor Green
    
    try {
        New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
        
        foreach ($file in $filesToDelete) {
            if (Test-Path $file) {
                $relativePath = Split-Path -Parent $file
                $backupPath = Join-Path $backupFolder $relativePath
                
                # Create backup directory structure
                if (-not (Test-Path $backupPath)) {
                    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
                }
                
                # Copy file to backup
                Copy-Item $file -Destination $backupPath -Force
            }
        }
        
        Write-Host "? Backup created: $backupFolder" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host "? Backup failed: $_" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}

# =============================================
# Delete Files
# =============================================

Write-Host "Deleting files..." -ForegroundColor Green
Write-Host ""

foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        if ($DryRun) {
            Write-Host "[DRY RUN] Would delete: $file" -ForegroundColor Yellow
            $deletedCount++
        }
        else {
            try {
                Remove-Item $file -Force
                Write-Host "? Deleted: $file" -ForegroundColor Green
                $deletedCount++
            }
            catch {
                Write-Host "? Failed to delete: $file - $_" -ForegroundColor Red
                $errors++
            }
        }
    }
    else {
        Write-Host "  Skipped (not found): $file" -ForegroundColor Gray
    }
}

# =============================================
# Summary
# =============================================

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   CLEANUP SUMMARY" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN MODE - No files were actually deleted]" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Files processed: $($filesToDelete.Count)" -ForegroundColor White
Write-Host "Files deleted:   $deletedCount" -ForegroundColor Green
Write-Host "Errors:          $errors" -ForegroundColor $(if ($errors -gt 0) { "Red" } else { "Green" })

if ($CreateBackup -and -not $DryRun) {
    Write-Host "Backup folder:   $backupFolder" -ForegroundColor Cyan
}

Write-Host ""

# =============================================
# Show what's being kept
# =============================================

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   IMPORTANT FILES PRESERVED" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$preservedFiles = @(
    "? Active Views (CustomerDashboard.cshtml, ManagerDashboard.cshtml, etc.)",
    "? Controllers (DashboardController.cs, AuthController.cs)",
    "? Services (All service files in BankApp.Services)",
    "? Repositories (All repository files in DB)",
    "? Important Docs (README.md, PROJECT_SUMMARY.md, HANDOFF.md)",
    "? Active SQL Scripts (Fix_*.sql, Update_*.sql, Create_FundTransfer_Table.sql)",
    "? Configuration files (Web.config, App.config, packages.config)"
)

foreach ($item in $preservedFiles) {
    Write-Host $item -ForegroundColor Green
}

Write-Host ""

# =============================================
# Next Steps
# =============================================

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "   NEXT STEPS" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Verify the application still builds:" -ForegroundColor Yellow
Write-Host "   > dotnet build" -ForegroundColor White
Write-Host ""

Write-Host "2. Test the application functionality" -ForegroundColor Yellow
Write-Host ""

Write-Host "3. If everything works, you can delete the backup:" -ForegroundColor Yellow
Write-Host "   > Remove-Item -Recurse -Force $backupFolder" -ForegroundColor White
Write-Host ""

if (-not $DeleteDiagnosticSQL) {
    Write-Host "4. [OPTIONAL] Delete diagnostic SQL files:" -ForegroundColor Yellow
    Write-Host "   > .\Cleanup_Workspace.ps1 -DeleteDiagnosticSQL" -ForegroundColor White
    Write-Host ""
}

if (-not $DeleteOldDocs) {
    Write-Host "5. [OPTIONAL] Delete old documentation:" -ForegroundColor Yellow
    Write-Host "   > .\Cleanup_Workspace.ps1 -DeleteOldDocs" -ForegroundColor White
    Write-Host ""
}

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Exit with error code if there were errors
if ($errors -gt 0) {
    exit 1
}
else {
    exit 0
}

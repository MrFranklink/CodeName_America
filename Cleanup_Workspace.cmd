@echo off
REM =============================================
REM Workspace Cleanup Script (CMD Version)
REM =============================================
REM This script removes unnecessary backup files and old documentation
REM while preserving all active/important files
REM
REM IMPORTANT: This creates a backup before deletion!
REM =============================================

setlocal EnableDelayedExpansion

echo =============================================
echo    WORKSPACE CLEANUP SCRIPT
echo =============================================
echo.

REM Get current directory
cd /d "%~dp0"
echo Working Directory: %CD%
echo.

REM Parse arguments
set DRY_RUN=0
set DELETE_DIAGNOSTIC=0
set DELETE_OLD_DOCS=0

:parse_args
if "%~1"=="" goto end_parse
if /i "%~1"=="-DryRun" set DRY_RUN=1
if /i "%~1"=="-DeleteDiagnosticSQL" set DELETE_DIAGNOSTIC=1
if /i "%~1"=="-DeleteOldDocs" set DELETE_OLD_DOCS=1
shift
goto parse_args
:end_parse

REM Create backup folder with timestamp
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (set mytime=%%a%%b)
set BACKUP_FOLDER=BACKUP_%mydate%_%mytime%

set DELETED_COUNT=0
set ERRORS=0

REM =============================================
REM Create Backup
REM =============================================

if %DRY_RUN%==0 (
    echo Creating backup...
    mkdir "%BACKUP_FOLDER%" 2>nul
    echo.
)

REM =============================================
REM Delete Files
REM =============================================

echo Deleting files...
echo.

REM Old View Backups
call :delete_file "Bank_App\Views\Dashboard\ChangePassword_OLD_V2.cshtml"
call :delete_file "Bank_App\Views\Dashboard\CustomerDashboard_OLD_BACKUP.cshtml"
call :delete_file "Bank_App\Views\Dashboard\CustomerDashboard_OLD_V2.cshtml"
call :delete_file "Bank_App\Views\Dashboard\CustomerDashboard_Modern.cshtml"
call :delete_file "Bank_App\Views\Dashboard\CustomerDashboard_Enhanced.cshtml"
call :delete_file "Bank_App\Views\Dashboard\EmployeeDashboard_OLD_V2.cshtml"
call :delete_file "Bank_App\Views\Dashboard\ManagerDashboard_Old.cshtml"
call :delete_file "Bank_App\Views\Dashboard\ManagerDashboard_OLD_V2.cshtml"
call :delete_file "Bank_App\Views\Dashboard\ManagerDashboard_New.cshtml"
call :delete_file "Bank_App\Views\Dashboard\_ManagerDashboardNewTabs.cshtml"
call :delete_file "Bank_App\Views\Dashboard\ManagerDashboard_Modern_Part1.cshtml"

REM Task 2 Documentation
call :delete_file "DOCS\Application_Approval_Workflow_Implementation.md"
call :delete_file "DOCS\Task2_Progress_Report.md"
call :delete_file "DOCS\Task2_Build_Error_Fix.md"
call :delete_file "DOCS\Task2_Revert_Complete.md"

REM Task 2 SQL Scripts
call :delete_file "SQL_Scripts\Create_Application_Tables.sql"
call :delete_file "SQL_Scripts\Revert_Task2_Drop_Application_Tables.sql"

REM Optional: Diagnostic SQL files
if %DELETE_DIAGNOSTIC%==1 (
    echo [OPTION] Deleting diagnostic SQL files...
    call :delete_file "SQL_Scripts\Check_Loan_Accounts_Status.sql"
    call :delete_file "SQL_Scripts\Diagnose_PAN_Column_Size.sql"
    call :delete_file "SQL_Scripts\Diagnose_Loan_Account_Error.sql"
    call :delete_file "SQL_Scripts\Check_Employee_Constraints.sql"
    call :delete_file "SQL_Scripts\Diagnose_Employee_Registration.sql"
    call :delete_file "SQL_Scripts\Find_Transactiontype_Check_Constraint.sql"
    call :delete_file "SQL_Scripts\Verify_Transaction_Types_Length.sql"
    call :delete_file "SQL_Scripts\Check_Transactiontype_Column_Size.sql"
)

REM Optional: Old documentation files
if %DELETE_OLD_DOCS%==1 (
    echo [OPTION] Deleting old documentation files...
    call :delete_file "DOCS\Build_Fix_Temporary_Solution.md"
    call :delete_file "DOCS\Workspace_Cleanup_Summary.md"
    call :delete_file "DOCS\UI_Downgrade_Summary.md"
    call :delete_file "DOCS\Entity_Validation_Error_Fix.md"
    call :delete_file "DOCS\Employee_Registration_Error_Fix.md"
    call :delete_file "DOCS\Loan_Account_Error_Fix.md"
    call :delete_file "DOCS\Fix_Pan_Column_Size_VARCHAR10.md"
    call :delete_file "DOCS\PAN_Column_Resize_Fix.md"
    call :delete_file "DOCS\UserLogin_Fix_Summary.md"
    call :delete_file "DOCS\Constraint_Fix_Complete.md"
    call :delete_file "DOCS\Invalid_Date_Fix.md"
    call :delete_file "DOCS\Check_Constraint_Blocking_Transfers_Fix.md"
    call :delete_file "DOCS\Transactiontype_Column_Truncation_Fix.md"
    call :delete_file "DOCS\Transfer_Transaction_Display_Fix.md"
    call :delete_file "DOCS\Customer_Transaction_History_Fix.md"
    call :delete_file "DOCS\Transaction_Modal_Empty_Debug_Guide.md"
    call :delete_file "DOCS\UX_Fixes_Complete_Implementation.md"
    call :delete_file "DOCS\Auto_Open_Transaction_History_Implementation.md"
    call :delete_file "DOCS\Customer_Dashboard_Empty_State_Complete.md"
    call :delete_file "DOCS\Manager_Dashboard_Tab_Reorganization.md"
    call :delete_file "DOCS\Loan_EMI_Requirements_Match_Verification.md"
)

REM =============================================
REM Summary
REM =============================================

echo.
echo =============================================
echo    CLEANUP SUMMARY
echo =============================================
echo.

if %DRY_RUN%==1 (
    echo [DRY RUN MODE - No files were actually deleted]
    echo.
)

echo Files deleted:   %DELETED_COUNT%
echo Errors:          %ERRORS%

if %DRY_RUN%==0 (
    echo Backup folder:   %BACKUP_FOLDER%
)

echo.
echo =============================================
echo    IMPORTANT FILES PRESERVED
echo =============================================
echo.

echo Active Views (CustomerDashboard.cshtml, ManagerDashboard.cshtml, etc.)
echo Controllers (DashboardController.cs, AuthController.cs)
echo Services (All service files in BankApp.Services)
echo Repositories (All repository files in DB)
echo Important Docs (README.md, PROJECT_SUMMARY.md, HANDOFF.md)
echo Active SQL Scripts (Fix_*.sql, Update_*.sql, etc.)
echo Configuration files (Web.config, App.config, packages.config)

echo.
echo =============================================
echo    NEXT STEPS
echo =============================================
echo.

echo 1. Verify the application still builds:
echo    msbuild Bank_Destroyer.sln
echo.

echo 2. Test the application functionality
echo.

if %DRY_RUN%==0 (
    echo 3. If everything works, delete the backup:
    echo    rmdir /s /q %BACKUP_FOLDER%
    echo.
)

if %DELETE_DIAGNOSTIC%==0 (
    echo 4. [OPTIONAL] Delete diagnostic SQL files:
    echo    Cleanup_Workspace.cmd -DeleteDiagnosticSQL
    echo.
)

if %DELETE_OLD_DOCS%==0 (
    echo 5. [OPTIONAL] Delete old documentation:
    echo    Cleanup_Workspace.cmd -DeleteOldDocs
    echo.
)

echo =============================================
echo.

goto :eof

REM =============================================
REM Helper Function: Delete File
REM =============================================
:delete_file
set FILE_PATH=%~1

if exist "%FILE_PATH%" (
    if %DRY_RUN%==1 (
        echo [DRY RUN] Would delete: %FILE_PATH%
        set /a DELETED_COUNT+=1
    ) else (
        REM Backup file first
        for %%F in ("%FILE_PATH%") do set FILE_DIR=%%~dpF
        set BACKUP_PATH=%BACKUP_FOLDER%\%FILE_DIR%
        
        if not exist "%BACKUP_PATH%" mkdir "%BACKUP_PATH%" 2>nul
        copy "%FILE_PATH%" "%BACKUP_PATH%" >nul 2>&1
        
        REM Delete file
        del /f /q "%FILE_PATH%" 2>nul
        if !errorlevel! equ 0 (
            echo Deleted: %FILE_PATH%
            set /a DELETED_COUNT+=1
        ) else (
            echo Failed to delete: %FILE_PATH%
            set /a ERRORS+=1
        )
    )
) else (
    echo   Skipped (not found): %FILE_PATH%
)
goto :eof

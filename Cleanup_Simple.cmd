@echo off
REM Simple Cleanup Script - No fancy features, just works!

echo.
echo ========================================
echo   WORKSPACE CLEANUP
echo ========================================
echo.

REM Check for dry run
if /i "%1"=="-DryRun" (
    echo [DRY RUN MODE - Preview only]
    echo.
    goto preview
)

REM Create backup
echo Creating backup folder...
set BACKUP=BACKUP_%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%
set BACKUP=%BACKUP: =0%
mkdir "%BACKUP%" 2>nul
echo Backup: %BACKUP%
echo.

REM Delete files
echo Deleting old files...
echo.

if exist "Bank_App\Views\Dashboard\ChangePassword_OLD_V2.cshtml" (
    copy "Bank_App\Views\Dashboard\ChangePassword_OLD_V2.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\ChangePassword_OLD_V2.cshtml"
    echo Deleted: ChangePassword_OLD_V2.cshtml
)

if exist "Bank_App\Views\Dashboard\CustomerDashboard_OLD_BACKUP.cshtml" (
    copy "Bank_App\Views\Dashboard\CustomerDashboard_OLD_BACKUP.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\CustomerDashboard_OLD_BACKUP.cshtml"
    echo Deleted: CustomerDashboard_OLD_BACKUP.cshtml
)

if exist "Bank_App\Views\Dashboard\CustomerDashboard_OLD_V2.cshtml" (
    copy "Bank_App\Views\Dashboard\CustomerDashboard_OLD_V2.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\CustomerDashboard_OLD_V2.cshtml"
    echo Deleted: CustomerDashboard_OLD_V2.cshtml
)

if exist "Bank_App\Views\Dashboard\CustomerDashboard_Modern.cshtml" (
    copy "Bank_App\Views\Dashboard\CustomerDashboard_Modern.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\CustomerDashboard_Modern.cshtml"
    echo Deleted: CustomerDashboard_Modern.cshtml
)

if exist "Bank_App\Views\Dashboard\CustomerDashboard_Enhanced.cshtml" (
    copy "Bank_App\Views\Dashboard\CustomerDashboard_Enhanced.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\CustomerDashboard_Enhanced.cshtml"
    echo Deleted: CustomerDashboard_Enhanced.cshtml
)

if exist "Bank_App\Views\Dashboard\EmployeeDashboard_OLD_V2.cshtml" (
    copy "Bank_App\Views\Dashboard\EmployeeDashboard_OLD_V2.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\EmployeeDashboard_OLD_V2.cshtml"
    echo Deleted: EmployeeDashboard_OLD_V2.cshtml
)

if exist "Bank_App\Views\Dashboard\ManagerDashboard_Old.cshtml" (
    copy "Bank_App\Views\Dashboard\ManagerDashboard_Old.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\ManagerDashboard_Old.cshtml"
    echo Deleted: ManagerDashboard_Old.cshtml
)

if exist "Bank_App\Views\Dashboard\ManagerDashboard_OLD_V2.cshtml" (
    copy "Bank_App\Views\Dashboard\ManagerDashboard_OLD_V2.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\ManagerDashboard_OLD_V2.cshtml"
    echo Deleted: ManagerDashboard_OLD_V2.cshtml
)

if exist "Bank_App\Views\Dashboard\ManagerDashboard_New.cshtml" (
    copy "Bank_App\Views\Dashboard\ManagerDashboard_New.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\ManagerDashboard_New.cshtml"
    echo Deleted: ManagerDashboard_New.cshtml
)

if exist "Bank_App\Views\Dashboard\_ManagerDashboardNewTabs.cshtml" (
    copy "Bank_App\Views\Dashboard\_ManagerDashboardNewTabs.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\_ManagerDashboardNewTabs.cshtml"
    echo Deleted: _ManagerDashboardNewTabs.cshtml
)

if exist "Bank_App\Views\Dashboard\ManagerDashboard_Modern_Part1.cshtml" (
    copy "Bank_App\Views\Dashboard\ManagerDashboard_Modern_Part1.cshtml" "%BACKUP%\" >nul 2>&1
    del /f /q "Bank_App\Views\Dashboard\ManagerDashboard_Modern_Part1.cshtml"
    echo Deleted: ManagerDashboard_Modern_Part1.cshtml
)

if exist "DOCS\Application_Approval_Workflow_Implementation.md" (
    copy "DOCS\Application_Approval_Workflow_Implementation.md" "%BACKUP%\" >nul 2>&1
    del /f /q "DOCS\Application_Approval_Workflow_Implementation.md"
    echo Deleted: Application_Approval_Workflow_Implementation.md
)

if exist "DOCS\Task2_Progress_Report.md" (
    copy "DOCS\Task2_Progress_Report.md" "%BACKUP%\" >nul 2>&1
    del /f /q "DOCS\Task2_Progress_Report.md"
    echo Deleted: Task2_Progress_Report.md
)

if exist "DOCS\Task2_Build_Error_Fix.md" (
    copy "DOCS\Task2_Build_Error_Fix.md" "%BACKUP%\" >nul 2>&1
    del /f /q "DOCS\Task2_Build_Error_Fix.md"
    echo Deleted: Task2_Build_Error_Fix.md
)

if exist "DOCS\Task2_Revert_Complete.md" (
    copy "DOCS\Task2_Revert_Complete.md" "%BACKUP%\" >nul 2>&1
    del /f /q "DOCS\Task2_Revert_Complete.md"
    echo Deleted: Task2_Revert_Complete.md
)

if exist "SQL_Scripts\Create_Application_Tables.sql" (
    copy "SQL_Scripts\Create_Application_Tables.sql" "%BACKUP%\" >nul 2>&1
    del /f /q "SQL_Scripts\Create_Application_Tables.sql"
    echo Deleted: Create_Application_Tables.sql
)

if exist "SQL_Scripts\Revert_Task2_Drop_Application_Tables.sql" (
    copy "SQL_Scripts\Revert_Task2_Drop_Application_Tables.sql" "%BACKUP%\" >nul 2>&1
    del /f /q "SQL_Scripts\Revert_Task2_Drop_Application_Tables.sql"
    echo Deleted: Revert_Task2_Drop_Application_Tables.sql
)

echo.
echo ========================================
echo CLEANUP COMPLETE!
echo ========================================
echo.
echo Backup folder: %BACKUP%
echo.
echo Next steps:
echo 1. Build the solution
echo 2. Test the application
echo 3. If OK, delete backup: rmdir /s /q %BACKUP%
echo.
goto end

:preview
echo These files would be deleted:
echo.
if exist "Bank_App\Views\Dashboard\ChangePassword_OLD_V2.cshtml" echo - ChangePassword_OLD_V2.cshtml
if exist "Bank_App\Views\Dashboard\CustomerDashboard_OLD_BACKUP.cshtml" echo - CustomerDashboard_OLD_BACKUP.cshtml
if exist "Bank_App\Views\Dashboard\CustomerDashboard_OLD_V2.cshtml" echo - CustomerDashboard_OLD_V2.cshtml
if exist "Bank_App\Views\Dashboard\CustomerDashboard_Modern.cshtml" echo - CustomerDashboard_Modern.cshtml
if exist "Bank_App\Views\Dashboard\CustomerDashboard_Enhanced.cshtml" echo - CustomerDashboard_Enhanced.cshtml
if exist "Bank_App\Views\Dashboard\EmployeeDashboard_OLD_V2.cshtml" echo - EmployeeDashboard_OLD_V2.cshtml
if exist "Bank_App\Views\Dashboard\ManagerDashboard_Old.cshtml" echo - ManagerDashboard_Old.cshtml
if exist "Bank_App\Views\Dashboard\ManagerDashboard_OLD_V2.cshtml" echo - ManagerDashboard_OLD_V2.cshtml
if exist "Bank_App\Views\Dashboard\ManagerDashboard_New.cshtml" echo - ManagerDashboard_New.cshtml
if exist "Bank_App\Views\Dashboard\_ManagerDashboardNewTabs.cshtml" echo - _ManagerDashboardNewTabs.cshtml
if exist "Bank_App\Views\Dashboard\ManagerDashboard_Modern_Part1.cshtml" echo - ManagerDashboard_Modern_Part1.cshtml
if exist "DOCS\Application_Approval_Workflow_Implementation.md" echo - Application_Approval_Workflow_Implementation.md
if exist "DOCS\Task2_Progress_Report.md" echo - Task2_Progress_Report.md
if exist "DOCS\Task2_Build_Error_Fix.md" echo - Task2_Build_Error_Fix.md
if exist "DOCS\Task2_Revert_Complete.md" echo - Task2_Revert_Complete.md
if exist "SQL_Scripts\Create_Application_Tables.sql" echo - Create_Application_Tables.sql
if exist "SQL_Scripts\Revert_Task2_Drop_Application_Tables.sql" echo - Revert_Task2_Drop_Application_Tables.sql
echo.
echo To delete these files, run: Cleanup_Simple.cmd
echo.

:end

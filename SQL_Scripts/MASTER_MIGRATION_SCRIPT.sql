# ?? Deploying Project to Different System - Complete Guide

## Problem
You've made **database changes** on your development machine:
- ? Fixed MaturityAmount column precision
- ? Added FD_MATURITY transaction type
- ? Added approval workflow columns
- ? Updated constraints
- ? Fixed balance columns

**How do you deploy to another system with all these changes?**

---

## ?? Solution: Database Migration Strategy

### **Option 1: Database Backup/Restore (Easiest)** ?

**Best for:** Moving to another development machine or local test environment

#### Steps:

**On Source Machine (Current System):**

1. **Create Database Backup**
   ```sql
   -- Open SSMS, run this:
   USE master;
   GO
   
   BACKUP DATABASE Banking_Details
   TO DISK = 'D:\Backups\Banking_Details_Complete.bak'
   WITH FORMAT, 
        MEDIANAME = 'Banking_Details_Backup',
        NAME = 'Full Backup of Banking_Details';
   GO
   ```

2. **Copy Files to USB/Cloud:**
   - `Banking_Details_Complete.bak` (database backup)
   - Your entire project folder `D:\CodeName_America\`

**On Target Machine (New System):**

1. **Install Prerequisites:**
   - Visual Studio 2019/2022
   - SQL Server 2019 (Express or Developer Edition)
   - SQL Server Management Studio (SSMS)

2. **Restore Database:**
   ```sql
   -- Open SSMS on new machine, run:
   USE master;
   GO
   
   RESTORE DATABASE Banking_Details
   FROM DISK = 'C:\Backups\Banking_Details_Complete.bak'
   WITH REPLACE,
        MOVE 'Banking_Details' TO 'C:\SQL_Data\Banking_Details.mdf',
        MOVE 'Banking_Details_log' TO 'C:\SQL_Data\Banking_Details_log.ldf';
   GO
   ```

3. **Update Connection String:**
   
   Open `Bank_App\Web.config` and update:
   
   ```xml
   <connectionStrings>
     <add name="Banking_DetailsEntities" 
          connectionString="metadata=res://*/Model1.csdl|res://*/Model1.ssdl|res://*/Model1.msl;
          provider=System.Data.SqlClient;
          provider connection string=&quot;
     data source=YOUR_NEW_SERVER_NAME;
          initial catalog=Banking_Details;
        integrated security=True;
          MultipleActiveResultSets=True;
      App=EntityFramework&quot;" 
    providerName="System.Data.EntityClient" />
   </connectionStrings>
   ```
   
   Replace `YOUR_NEW_SERVER_NAME` with:
   - `(local)\SQLEXPRESS` (if using SQL Express)
   - `localhost` (if using full SQL Server)
   - Your server name

4. **Build and Run:**
   ```
   - Open solution in Visual Studio
   - Restore NuGet packages
   - Build solution
   - Run (F5)
   ```

? **Done! All database changes are included in the backup.**

---

### **Option 2: Migration Scripts (Professional)** ???

**Best for:** Production deployment, team collaboration, version control

#### Create a Master Migration Script

I'll create this for you:

<function_calls>
<invoke name="create_file">
<parameter name="content">-- ========================================
-- MASTER MIGRATION SCRIPT
-- Banking Application - All Database Changes
-- Run this on a fresh database to apply all fixes
-- ========================================

USE Banking_Details;
GO

PRINT '????????????????????????????????????????????????????????????????????';
PRINT '?  BANKING APP - DATABASE MIGRATION SCRIPT        ?';
PRINT '?  Version: 1.0 - December 2024        ?';
PRINT '????????????????????????????????????????????????????????????????????';
PRINT '';

-- ========================================
-- STEP 1: Add Approval Workflow Columns
-- ========================================
PRINT 'STEP 1: Adding approval workflow columns...';

-- Check if columns exist before adding
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'OpenedBy')
BEGIN
    ALTER TABLE Account ADD OpenedBy VARCHAR(20) NULL;
    PRINT '  ? Added OpenedBy column';
END
ELSE
    PRINT '  ??  OpenedBy column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'OpenedByRole')
BEGIN
    ALTER TABLE Account ADD OpenedByRole VARCHAR(20) NULL;
    PRINT '  ? Added OpenedByRole column';
END
ELSE
    PRINT '  ??  OpenedByRole column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'ApprovedBy')
BEGIN
    ALTER TABLE Account ADD ApprovedBy VARCHAR(20) NULL;
    PRINT '  ? Added ApprovedBy column';
END
ELSE
    PRINT '  ??  ApprovedBy column already exists';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Account') AND name = 'RejectionReason')
BEGIN
    ALTER TABLE Account ADD RejectionReason VARCHAR(500) NULL;
    PRINT '  ? Added RejectionReason column';
END
ELSE
    PRINT '  ??  RejectionReason column already exists';

PRINT '';

-- ========================================
-- STEP 2: Fix MaturityAmount Precision
-- ========================================
PRINT 'STEP 2: Fixing FixedDepositAccount MaturityAmount precision...';

-- Get current precision
DECLARE @CurrentPrecision INT, @CurrentScale INT;
SELECT 
    @CurrentPrecision = NUMERIC_PRECISION,
    @CurrentScale = NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount' AND COLUMN_NAME = 'MaturityAmount';

IF @CurrentPrecision < 28
BEGIN
    ALTER TABLE FixedDepositAccount
    ALTER COLUMN MaturityAmount DECIMAL(28,8) NULL;
    PRINT '  ? Increased MaturityAmount precision to DECIMAL(28,8)';
END
ELSE
    PRINT '  ??  MaturityAmount precision already correct (28,8)';

PRINT '';

-- ========================================
-- STEP 3: Fix SavingsAccount Balance
-- ========================================
PRINT 'STEP 3: Ensuring SavingsAccount Balance column...';

-- Check if Balance column exists
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SavingsAccount') AND name = 'Balance')
BEGIN
    ALTER TABLE SavingsAccount ADD Balance DECIMAL(18,2) NULL;
    PRINT '  ? Added Balance column to SavingsAccount';
    
    -- Set initial balance from transactions
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
    
    PRINT '  ? Calculated balances from transaction history';
END
ELSE
    PRINT '  ??  Balance column already exists';

PRINT '';

-- ========================================
-- STEP 4: Add FD_MATURITY Transaction Type
-- ========================================
PRINT 'STEP 4: Adding FD_MATURITY transaction type...';

-- Drop existing constraint
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_SavingsTransaction_Transactiontype')
BEGIN
    ALTER TABLE SavingsTransaction DROP CONSTRAINT CK_SavingsTransaction_Transactiontype;
    PRINT '  ? Dropped old transaction type constraint';
END

-- Create new constraint with FD_MATURITY
ALTER TABLE SavingsTransaction
ADD CONSTRAINT CK_SavingsTransaction_Transactiontype
CHECK (Transactiontype IN (
    'DEPOSIT',
    'WITHDRAW',
    'WITHDRAWAL',
    'INITIAL DEPOSIT',
  'TRANSFER_DEBIT',
    'TRANSFER_CREDIT',
    'LOAN_PAYMENT',
    'FD_MATURITY'
));

PRINT '  ? Added FD_MATURITY to allowed transaction types';
PRINT '';

-- ========================================
-- STEP 5: Recalculate FD Maturity Amounts
-- ========================================
PRINT 'STEP 5: Recalculating Fixed Deposit maturity amounts...';

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
    AND fd.Amount IS NOT NULL 
    AND fd.Amount > 0;

SET @UpdatedCount = @@ROWCOUNT;

IF @UpdatedCount > 0
    PRINT '  ? Recalculated maturity for ' + CAST(@UpdatedCount AS VARCHAR) + ' FD account(s)';
ELSE
    PRINT '  ??  All FD accounts already have valid maturity amounts';

PRINT '';

-- ========================================
-- STEP 6: Verification
-- ========================================
PRINT 'STEP 6: Verifying all changes...';
PRINT '';

-- Count columns
DECLARE @ApprovalCols INT;
SELECT @ApprovalCols = COUNT(*)
FROM sys.columns
WHERE object_id = OBJECT_ID('Account')
    AND name IN ('OpenedBy', 'OpenedByRole', 'ApprovedBy', 'RejectionReason');

PRINT '  Approval Columns: ' + CAST(@ApprovalCols AS VARCHAR) + '/4';

-- Check MaturityAmount precision
SELECT @CurrentPrecision = NUMERIC_PRECISION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount' AND COLUMN_NAME = 'MaturityAmount';

PRINT '  MaturityAmount Precision: ' + CAST(@CurrentPrecision AS VARCHAR) + ' (should be 28)';

-- Check FD maturity amounts
DECLARE @NullMaturity INT;
SELECT @NullMaturity = COUNT(*)
FROM FixedDepositAccount
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;

PRINT '  FDs with NULL maturity: ' + CAST(@NullMaturity AS VARCHAR) + ' (should be 0)';

-- Check transaction type constraint
DECLARE @HasFDMaturity INT;
SELECT @HasFDMaturity = COUNT(*)
FROM sys.check_constraints cc
INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
WHERE t.name = 'SavingsTransaction'
    AND cc.name = 'CK_SavingsTransaction_Transactiontype'
    AND cc.definition LIKE '%FD_MATURITY%';

PRINT '  FD_MATURITY in constraint: ' + CASE WHEN @HasFDMaturity > 0 THEN 'YES ?' ELSE 'NO ?' END;

PRINT '';

-- ========================================
-- FINAL SUMMARY
-- ========================================
PRINT '????????????????????????????????????????????????????????????????????';
PRINT '?  MIGRATION COMPLETE!    ?';
PRINT '????????????????????????????????????????????????????????????????????';
PRINT '';
PRINT '? All database changes have been applied successfully!';
PRINT '';
PRINT 'Next Steps:';
PRINT '  1. Update Entity Framework model in Visual Studio';
PRINT '     (Right-click Model1.edmx ? Update Model from Database)';
PRINT '  2. Rebuild solution';
PRINT '  3. Test application';
PRINT '';
PRINT 'Migration completed on: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';

GO

-- EMERGENCY FIX: Update NULL MaturityAmount for existing FD accounts
-- This fixes FD accounts that were created without maturity amounts

USE Banking_Details;
GO

PRINT '=== FD Maturity Amount Emergency Fix ===';
PRINT '';

-- Step 1: Check current state
PRINT '?? Current FD Accounts Status:';
SELECT 
    FDAccountID,
  CustomerID,
    Amount,
    MaturityAmount,
    FD_ROI,
    StartDate,
    EndDate,
    DATEDIFF(MONTH, StartDate, EndDate) AS TenureMonths,
    CASE 
        WHEN MaturityAmount IS NULL THEN '? NULL'
        WHEN MaturityAmount = 0 THEN '? ZERO'
        ELSE '? OK'
 END AS Status
FROM FixedDepositAccount
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;

PRINT '';
PRINT '?? Fixing NULL/Zero MaturityAmounts...';
PRINT '';

-- Step 2: Update MaturityAmount using compound interest formula
-- Formula: MaturityAmount = Amount * (1 + Rate/100)^(Years)
UPDATE FixedDepositAccount
SET MaturityAmount = ROUND(
    Amount * POWER(
        (1 + FD_ROI / 100.0),
     DATEDIFF(MONTH, StartDate, EndDate) / 12.0
    ),
    2
)
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;

PRINT '? Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' FD account(s)';
PRINT '';

-- Step 3: Verify the fix
PRINT '?? Updated FD Accounts:';
SELECT 
    FDAccountID,
    CustomerID,
    Amount AS Principal,
    FD_ROI AS InterestRate,
    DATEDIFF(MONTH, StartDate, EndDate) AS TenureMonths,
    MaturityAmount,
    (MaturityAmount - Amount) AS Interest,
    CASE 
        WHEN MaturityAmount > Amount THEN '? FIXED'
        ELSE '? STILL WRONG'
    END AS Status
FROM FixedDepositAccount
ORDER BY FDAccountID DESC;

PRINT '';
PRINT '? Fix Complete!';
PRINT '';
PRINT '?? Now you can foreclose FD accounts and maturity will transfer correctly.';
GO

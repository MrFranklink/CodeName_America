-- Diagnostic script to check Fixed Deposit MaturityAmount values

USE Banking_Details;
GO

PRINT '=== Fixed Deposit MaturityAmount Diagnostic ===';
PRINT '';

-- Check all FD accounts
SELECT 
    fd.FDAccountID,
    fd.CustomerID,
    fd.Amount AS 'Principal Amount',
    fd.MaturityAmount,
    fd.FD_ROI AS 'Interest Rate (%)',
    fd.StartDate,
  fd.EndDate,
    DATEDIFF(MONTH, fd.StartDate, fd.EndDate) AS 'Tenure (Months)',
    a.Status,
    a.OpenDate
FROM FixedDepositAccount fd
JOIN Account a ON fd.FDAccountID = a.AccountID
ORDER BY fd.FDAccountID;

PRINT '';
PRINT '=== FD Accounts with NULL or 0 MaturityAmount ===';

SELECT 
    fd.FDAccountID,
    fd.CustomerID,
    fd.Amount AS 'Principal',
    fd.MaturityAmount AS 'Current Maturity (PROBLEM)',
    fd.FD_ROI AS 'Rate',
    DATEDIFF(MONTH, fd.StartDate, fd.EndDate) AS 'Tenure',
    a.Status
FROM FixedDepositAccount fd
JOIN Account a ON fd.FDAccountID = a.AccountID
WHERE fd.MaturityAmount IS NULL OR fd.MaturityAmount = 0;

PRINT '';
PRINT '=== Column Data Type Check ===';

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount'
    AND COLUMN_NAME IN ('Amount', 'MaturityAmount');

PRINT '';
PRINT 'Done!';
GO

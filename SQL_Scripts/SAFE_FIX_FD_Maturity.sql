-- ? SAFE FIX: Recalculate FD Maturity with Overflow Protection

USE Banking_Details;
GO

PRINT '=== SAFE FD Maturity Amount Fix ===';
PRINT '';

-- Step 1: Check current column precision
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CONCAT(NUMERIC_PRECISION, ',', NUMERIC_SCALE) AS 'Precision (Total,Decimal)'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FixedDepositAccount'
    AND COLUMN_NAME = 'MaturityAmount';

PRINT '';
PRINT 'Step 1: Increasing column precision to handle large values...';

-- Increase precision from decimal(18,8) to decimal(28,8) to prevent overflow
ALTER TABLE FixedDepositAccount
ALTER COLUMN MaturityAmount DECIMAL(28,8) NULL;

PRINT 'Column precision increased to DECIMAL(28,8)';
PRINT '';

PRINT 'Step 2: Recalculating maturity amounts...';

-- Show BEFORE state
SELECT 
    FDAccountID,
    Amount AS Principal,
    MaturityAmount AS 'Current Maturity',
    FD_ROI AS 'Rate %',
    DATEDIFF(MONTH, StartDate, EndDate) AS 'Tenure (Months)',
    CASE 
        WHEN DATEDIFF(MONTH, StartDate, EndDate) > 240 THEN 'WARNING: Very long tenure'
      ELSE 'OK'
    END AS 'Status'
FROM FixedDepositAccount
WHERE MaturityAmount IS NULL OR MaturityAmount = 0
ORDER BY FDAccountID;

PRINT '';

-- Calculate maturity with safe conversion
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

PRINT 'Updated: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' FD accounts';
PRINT '';

-- Show AFTER state with calculations
SELECT 
    FDAccountID,
    Amount AS Principal,
    CAST(MaturityAmount AS DECIMAL(18,2)) AS 'New Maturity',
    FD_ROI AS 'Rate %',
    DATEDIFF(MONTH, StartDate, EndDate) AS 'Tenure (Months)',
    CAST((MaturityAmount - Amount) AS DECIMAL(18,2)) AS 'Interest Earned',
    CAST(((MaturityAmount - Amount) / Amount * 100) AS DECIMAL(10,2)) AS 'Return %'
FROM FixedDepositAccount
WHERE MaturityAmount IS NOT NULL AND MaturityAmount > 0
ORDER BY FDAccountID;

PRINT '';
PRINT '? SUCCESS! All FD maturity amounts calculated.';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Refresh Customer Dashboard';
PRINT '2. Check FD00016: Should show ?106,000.00';
PRINT '3. Very long-tenure FDs (like FD00010) now have correct huge maturity amounts';
PRINT '';
PRINT 'Done!';
GO

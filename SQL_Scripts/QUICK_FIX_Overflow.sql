-- ? SIMPLEST FIX: 2 Steps to Fix FD Maturity Overflow

USE Banking_Details;
GO

-- Step 1: Increase column size (prevents overflow)
PRINT 'Step 1: Fixing column size...';
ALTER TABLE FixedDepositAccount
ALTER COLUMN MaturityAmount DECIMAL(28,8) NULL;
PRINT '? Column size increased';
PRINT '';

-- Step 2: Calculate maturity amounts
PRINT 'Step 2: Calculating maturity amounts...';
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

PRINT '? Updated: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' FD accounts';
PRINT '';

-- Verify results
SELECT 
    FDAccountID,
    CAST(Amount AS DECIMAL(18,2)) AS Principal,
    CAST(MaturityAmount AS DECIMAL(18,2)) AS Maturity,
    FD_ROI AS 'Rate%',
    DATEDIFF(MONTH, StartDate, EndDate) AS Tenure
FROM FixedDepositAccount
ORDER BY FDAccountID;

PRINT '';
PRINT '? DONE! Refresh Customer Dashboard.';
GO

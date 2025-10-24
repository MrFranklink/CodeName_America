-- ? QUICK FIX: Recalculate MaturityAmount for all Fixed Deposits

USE Banking_Details;
GO

PRINT '=== Recalculating MaturityAmount for Fixed Deposits ===';
PRINT '';

-- Backup current values
IF OBJECT_ID('tempdb..#FD_Backup') IS NOT NULL DROP TABLE #FD_Backup;

SELECT 
  FDAccountID,
    Amount,
    MaturityAmount AS Old_MaturityAmount,
    FD_ROI,
 StartDate,
    EndDate
INTO #FD_Backup
FROM FixedDepositAccount;

PRINT 'Backed up ' + CAST(@@ROWCOUNT AS VARCHAR) + ' FD records';
PRINT '';

-- Recalculate Maturity Amount using compound interest formula
-- A = P(1 + r/100)^(t/12)

UPDATE fd
SET MaturityAmount = 
    fd.Amount * 
    POWER(
        (1 + fd.FD_ROI / 100), 
        (DATEDIFF(MONTH, fd.StartDate, fd.EndDate) / 12.0)
  )
FROM FixedDepositAccount fd
WHERE fd.Amount IS NOT NULL AND fd.Amount > 0;

PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR) + ' FD accounts';
PRINT '';

-- Show comparison
SELECT 
    b.FDAccountID,
    b.Amount AS Principal,
    b.FD_ROI AS 'Rate %',
    DATEDIFF(MONTH, b.StartDate, b.EndDate) AS 'Tenure (Months)',
    b.Old_MaturityAmount AS 'Old Maturity',
    fd.MaturityAmount AS 'New Maturity',
    (fd.MaturityAmount - b.Old_MaturityAmount) AS 'Difference'
FROM #FD_Backup b
JOIN FixedDepositAccount fd ON b.FDAccountID = fd.FDAccountID
WHERE b.Old_MaturityAmount IS NULL OR b.Old_MaturityAmount = 0;

PRINT '';
PRINT 'Done! Refresh your customer dashboard to see updated FD balances.';
GO

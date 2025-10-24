-- Quick Diagnostic: Check FD Maturity Amount Issue
-- Run this to see which FD accounts have NULL/0 maturity amounts

USE Banking_Details;
GO

PRINT '?????????????????????????????????????????????????????????????';
PRINT '?  FD MATURITY AMOUNT DIAGNOSTIC        ?';
PRINT '?????????????????????????????????????????????????????????????';
PRINT '';

-- Check 1: FD Accounts with NULL or 0 MaturityAmount
PRINT '?? CHECK 1: FD Accounts with Missing Maturity Amounts';
PRINT '?????????????????????????????????????????????????????????';

DECLARE @BadCount INT;
SELECT @BadCount = COUNT(*)
FROM FixedDepositAccount
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;

IF @BadCount > 0
BEGIN
    PRINT '? Found ' + CAST(@BadCount AS VARCHAR) + ' FD account(s) with NULL/0 maturity amounts!';
    PRINT '';
    
    SELECT 
   FDAccountID,
CustomerID,
        Amount AS 'Principal ?',
        FD_ROI AS 'Rate %',
        DATEDIFF(MONTH, StartDate, EndDate) AS 'Tenure (months)',
    MaturityAmount AS 'Maturity ?',
      CASE 
            WHEN MaturityAmount IS NULL THEN '? NULL - NEEDS FIX'
        WHEN MaturityAmount = 0 THEN '? ZERO - NEEDS FIX'
        ELSE '? OK'
        END AS 'Status'
    FROM FixedDepositAccount
    WHERE MaturityAmount IS NULL OR MaturityAmount = 0
    ORDER BY FDAccountID;
  
    PRINT '';
    PRINT '??  ACTION REQUIRED:';
    PRINT '   Run: SQL_Scripts/EMERGENCY_Fix_MaturityAmount.sql';
    PRINT '';
END
ELSE
BEGIN
    PRINT '? All FD accounts have valid maturity amounts!';
    PRINT '';
END

-- Check 2: Recent FD_MATURITY Transactions
PRINT '?? CHECK 2: Recent FD_MATURITY Transactions';
PRINT '?????????????????????????????????????????????????????????';

DECLARE @RecentCount INT;
SELECT @RecentCount = COUNT(*)
FROM SavingsTransaction
WHERE Transactiontype = 'FD_MATURITY';

IF @RecentCount > 0
BEGIN
    PRINT 'Found ' + CAST(@RecentCount AS VARCHAR) + ' FD_MATURITY transaction(s)';
    PRINT '';
    
    SELECT TOP 10
      Transactionid,
        SBAccountID,
      Amount AS 'Transfer Amount ?',
        Transationdate AS 'Date',
        CASE 
    WHEN Amount = 0 THEN '? ZERO - FD had NULL maturity'
            WHEN Amount > 0 THEN '? OK'
  ELSE '??  Check'
 END AS 'Status'
    FROM SavingsTransaction
    WHERE Transactiontype = 'FD_MATURITY'
    ORDER BY Transationdate DESC;
 
    PRINT '';
    
    -- Check if any transactions have Amount = 0
    DECLARE @ZeroTransfers INT;
    SELECT @ZeroTransfers = COUNT(*)
    FROM SavingsTransaction
    WHERE Transactiontype = 'FD_MATURITY' AND Amount = 0;

    IF @ZeroTransfers > 0
    BEGIN
    PRINT '? Found ' + CAST(@ZeroTransfers AS VARCHAR) + ' FD_MATURITY transaction(s) with ZERO amount!';
        PRINT '   This confirms the FD MaturityAmount was NULL when closed.';
        PRINT '   Fix: Run SQL_Scripts/EMERGENCY_Fix_MaturityAmount.sql';
        PRINT '';
    END
    ELSE
    BEGIN
        PRINT '? All FD_MATURITY transactions have proper amounts!';
 PRINT '';
    END
END
ELSE
BEGIN
    PRINT 'No FD_MATURITY transactions found yet.';
    PRINT '';
END

-- Check 3: All FD Accounts Summary
PRINT '?? CHECK 3: All FD Accounts Summary';
PRINT '?????????????????????????????????????????????????????????';

SELECT 
    a.AccountID,
    a.CustomerID,
    a.Status AS 'Account Status',
    fd.Amount AS 'Principal ?',
  fd.FD_ROI AS 'Rate %',
    DATEDIFF(MONTH, fd.StartDate, fd.EndDate) AS 'Tenure (months)',
    fd.MaturityAmount AS 'Maturity ?',
    CASE 
        WHEN fd.MaturityAmount IS NULL THEN '? NULL'
  WHEN fd.MaturityAmount = 0 THEN '? ZERO'
     WHEN fd.MaturityAmount < fd.Amount THEN '??  Less than principal'
   WHEN fd.MaturityAmount = fd.Amount THEN '??  No interest'
        WHEN fd.MaturityAmount > fd.Amount THEN '? OK'
 ELSE '??  Check'
    END AS 'Maturity Status',
    fd.StartDate,
    fd.EndDate
FROM Account a
INNER JOIN FixedDepositAccount fd ON a.AccountID = fd.FDAccountID
ORDER BY a.AccountID DESC;

PRINT '';

-- Check 4: Calculate What Maturity SHOULD BE
PRINT '?? CHECK 4: Maturity Amount Calculation Check';
PRINT '?????????????????????????????????????????????????????????';

SELECT 
    FDAccountID,
    Amount AS 'Principal ?',
    FD_ROI AS 'Rate %',
    DATEDIFF(MONTH, StartDate, EndDate) AS 'Tenure (months)',
    MaturityAmount AS 'Current Maturity ?',
    ROUND(
 Amount * POWER(
        (1 + FD_ROI / 100.0),
    DATEDIFF(MONTH, StartDate, EndDate) / 12.0
        ),
        2
    ) AS 'Should Be ?',
    ROUND(
     Amount * POWER(
       (1 + FD_ROI / 100.0),
      DATEDIFF(MONTH, StartDate, EndDate) / 12.0
        ) - Amount,
  2
    ) AS 'Interest ?',
    CASE 
        WHEN MaturityAmount IS NULL OR MaturityAmount = 0 THEN '? NEEDS UPDATE'
        WHEN ABS(MaturityAmount - ROUND(Amount * POWER((1 + FD_ROI / 100.0), DATEDIFF(MONTH, StartDate, EndDate) / 12.0), 2)) < 1 THEN '? CORRECT'
        ELSE '??  MISMATCH'
    END AS 'Calculation Status'
FROM FixedDepositAccount
ORDER BY FDAccountID DESC;

PRINT '';
PRINT '?????????????????????????????????????????????????????????????';
PRINT '?  DIAGNOSTIC COMPLETE    ?';
PRINT '?????????????????????????????????????????????????????????????';
PRINT '';

-- Summary
PRINT '?? SUMMARY:';
PRINT '?????????????????????????????????????????????????????????';

DECLARE @TotalFDs INT, @NullMaturity INT, @ZeroMaturity INT;

SELECT @TotalFDs = COUNT(*) FROM FixedDepositAccount;
SELECT @NullMaturity = COUNT(*) FROM FixedDepositAccount WHERE MaturityAmount IS NULL;
SELECT @ZeroMaturity = COUNT(*) FROM FixedDepositAccount WHERE MaturityAmount = 0;

PRINT 'Total FD Accounts: ' + CAST(@TotalFDs AS VARCHAR);
PRINT 'With NULL Maturity: ' + CAST(@NullMaturity AS VARCHAR);
PRINT 'With ZERO Maturity: ' + CAST(@ZeroMaturity AS VARCHAR);
PRINT 'Need Fixing: ' + CAST((@NullMaturity + @ZeroMaturity) AS VARCHAR);

PRINT '';

IF (@NullMaturity + @ZeroMaturity) > 0
BEGIN
    PRINT '? ACTION REQUIRED:';
 PRINT '   1. Run: SQL_Scripts/EMERGENCY_Fix_MaturityAmount.sql';
    PRINT '   2. Rebuild solution in Visual Studio';
    PRINT '   3. Test FD foreclose again';
    PRINT '';
END
ELSE
BEGIN
    PRINT '? NO ACTION REQUIRED - All FD accounts have valid maturity amounts!';
    PRINT '';
    PRINT '?? If FD foreclose still shows Amount = 0:';
    PRINT '   - Check Visual Studio Output window for debug logs';
    PRINT '   - Verify FD account exists and is OPEN';
    PRINT ' - Ensure customer has a savings account';
    PRINT '';
END

GO

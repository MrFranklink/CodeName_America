-- Add FD_MATURITY to allowed transaction types

USE Banking_Details;
GO

PRINT '=== Adding FD_MATURITY Transaction Type ===';

-- Drop existing constraint
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_SavingsTransaction_Transactiontype')
BEGIN
    ALTER TABLE SavingsTransaction DROP CONSTRAINT CK_SavingsTransaction_Transactiontype;
    PRINT 'Dropped existing constraint';
END

-- Create new constraint with FD_MATURITY included
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
    'FD_MATURITY'        -- NEW: For FD closure transfer
));

PRINT 'Added FD_MATURITY to transaction types';
PRINT 'Done!';
GO

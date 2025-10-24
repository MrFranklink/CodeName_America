-- ============================================================
-- CREATE BANKING DATABASE TABLES - EXACT FOR YOUR APP
-- ============================================================
-- This script matches your Entity Framework Model1.edmx exactly
-- Run this in SQL Server Management Studio
-- ============================================================
Create Database Banking_Details
USE Banking_Details;
GO

PRINT '========================================';
PRINT 'CREATING BANKING TABLES';
PRINT '========================================';
GO

-- Step 1: Create Core Tables (No Dependencies)

-- ============================================================
-- TABLE: Manager (ManagerID is VARCHAR, not auto-increment)
-- ============================================================
CREATE TABLE Manager (
    ManagerID VARCHAR(8) PRIMARY KEY,
    ManagerName VARCHAR(50) NOT NULL,
    PAN VARCHAR(10) NULL,
    UNIQUE (PAN)
);
GO
PRINT '✓ Manager table created';
GO

-- ============================================================
-- TABLE: Department (DeptId is CHAR)
-- ============================================================
CREATE TABLE Department (
    Deptid CHAR(6) PRIMARY KEY,
    Deptname VARCHAR(20) NOT NULL
);
GO
PRINT '✓ Department table created';
GO

-- ============================================================
-- TABLE: Employee
-- ============================================================
CREATE TABLE Employee (
    Empid VARCHAR(20) PRIMARY KEY,
    EmployeeName VARCHAR(20) NOT NULL,
    DeptId CHAR(6) NULL,
    Pan VARCHAR(10) NULL,
    FOREIGN KEY (DeptId) REFERENCES Department(Deptid),
    UNIQUE (Pan)
);
GO
PRINT '✓ Employee table created';
GO

-- ============================================================
-- TABLE: Customer (Custid is CHAR(8))
-- ============================================================
CREATE TABLE Customer (
    Custid CHAR(8) PRIMARY KEY,
    Custname VARCHAR(20) NOT NULL,
    DOB DATE NULL,
    Pan VARCHAR(10) NULL,
    Address VARCHAR(100) NULL,
    PhoneNumber VARCHAR(15) NULL,
    UNIQUE (Pan)
);
GO
PRINT '✓ Customer table created';
GO

-- ============================================================
-- TABLE: UserLogin
-- ============================================================
CREATE TABLE UserLogin (
    UserID VARCHAR(20) PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(15) NULL CHECK (Role IN ('MANAGER', 'EMPLOYEE', 'CUSTOMER')),
    ReferenceID VARCHAR(8) NULL
);
GO
PRINT '✓ UserLogin table created';
GO

-- Step 2: Create Account Tables

-- ============================================================
-- TABLE: Account (AccountID is CHAR(7))
-- ============================================================
CREATE TABLE Account (
    AccountID CHAR(7) PRIMARY KEY,
    AccountType VARCHAR(15) NULL,
    CustomerID CHAR(8) NULL,
    OpenedBy VARCHAR(20) NULL,
    OpenedByRole VARCHAR(10) NULL,
    OpenDate DATE NOT NULL,
    Status VARCHAR(10) NULL,
    ClosedDate DATE NULL,
    RejectionReason NVARCHAR(500) NULL,
    ApprovedBy VARCHAR(10) NULL,
    ApprovalDate DATETIME NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer(Custid)
);
GO
PRINT '✓ Account table created';
GO

-- ============================================================
-- TABLE: SavingsAccount (SBAccountID is CHAR(7))
-- ============================================================
CREATE TABLE SavingsAccount (
    SBAccountID CHAR(7) PRIMARY KEY,
    Customerid CHAR(8) NULL,
    Balance SMALLMONEY NULL,
    FOREIGN KEY (SBAccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (Customerid) REFERENCES Customer(Custid)
);
GO
PRINT '✓ SavingsAccount table created';
GO

-- ============================================================
-- TABLE: FixedDepositAccount (FDAccountID is CHAR(7))
-- ============================================================
CREATE TABLE FixedDepositAccount (
    FDAccountID CHAR(7) PRIMARY KEY,
    CustomerID CHAR(8) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    FD_ROI DECIMAL(4, 2) NOT NULL,
    Amount DECIMAL(12, 2) NULL,
    MaturityAmount NUMERIC(37, 11) NULL,
    FOREIGN KEY (FDAccountID) REFERENCES Account(AccountID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(Custid)
);
GO
PRINT '✓ FixedDepositAccount table created';
GO

-- ============================================================
-- TABLE: LoanAccount (Ln_accountid is CHAR(7))
-- ============================================================
CREATE TABLE LoanAccount (
    Ln_accountid CHAR(7) PRIMARY KEY,
    Customer CHAR(8) NOT NULL,
    loan_amount DECIMAL(12, 2) NULL,
    Start_date DATE NOT NULL,
    Tenure INT NOT NULL,
    Ln_roi DECIMAL(4, 2) NOT NULL,
    Emi DECIMAL(12, 2) NULL,
    FOREIGN KEY (Ln_accountid) REFERENCES Account(AccountID),
    FOREIGN KEY (Customer) REFERENCES Customer(Custid)
);
GO
PRINT '✓ LoanAccount table created';
GO

-- Step 3: Create Transaction Tables

-- ============================================================
-- TABLE: SavingsTransaction
-- ============================================================
CREATE TABLE SavingsTransaction (
    Transactionid INT PRIMARY KEY IDENTITY(1,1),
    SBAccountID CHAR(7) NOT NULL,
    Transationdate DATETIME NULL,
    Transactiontype VARCHAR(50) NOT NULL CHECK (Transactiontype IN (
        'DEPOSIT',
        'WITHDRAW',
        'WITHDRAWAL',
        'INITIAL DEPOSIT',
        'TRANSFER_DEBIT',
        'TRANSFER_CREDIT',
        'LOAN_PAYMENT'
    )),
    Amount DECIMAL(18, 2) NULL,
    FOREIGN KEY (SBAccountID) REFERENCES SavingsAccount(SBAccountID)
);
GO
PRINT '✓ SavingsTransaction table created';
GO

-- ============================================================
-- TABLE: LoanTransaction
-- ============================================================
CREATE TABLE LoanTransaction (
    Transactionno INT PRIMARY KEY IDENTITY(1,1),
    Ln_accountid CHAR(7) NOT NULL,
    Emidate DATETIME NULL,
    Amount DECIMAL(12, 2) NULL,
    Outstanding DECIMAL(12, 2) NULL,
    PaymentType VARCHAR(20) NULL,
    PaidBy CHAR(8) NULL,
    FOREIGN KEY (Ln_accountid) REFERENCES LoanAccount(Ln_accountid)
);
GO
PRINT '✓ LoanTransaction table created';
GO

-- ============================================================
-- TABLE: FDTransaction
-- ============================================================
CREATE TABLE FDTransaction (
    TransactionID INT PRIMARY KEY,
    FDAccountID CHAR(7) NULL,
    TransactionType VARCHAR(15) NULL,
    Amount SMALLMONEY NOT NULL,
    TransactionDate DATETIME NULL,
    FOREIGN KEY (FDAccountID) REFERENCES FixedDepositAccount(FDAccountID)
);
GO
PRINT '✓ FDTransaction table created';
GO

-- ============================================================
-- TABLE: FundTransfer
-- ============================================================
CREATE TABLE FundTransfer (
    TransferID INT PRIMARY KEY IDENTITY(1,1),
    FromAccountID CHAR(7) NOT NULL,
    ToAccountID CHAR(7) NOT NULL,
    Amount DECIMAL(12, 2) NOT NULL,
    TransferDate DATETIME NOT NULL,
    FromCustomerID CHAR(8) NOT NULL,
    ToCustomerID CHAR(8) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    Remarks VARCHAR(200) NULL,
    CONSTRAINT CK_FundTransfer_DifferentAccounts CHECK (FromAccountID != ToAccountID),
    FOREIGN KEY (FromAccountID) REFERENCES SavingsAccount(SBAccountID),
    FOREIGN KEY (ToAccountID) REFERENCES SavingsAccount(SBAccountID),
    FOREIGN KEY (FromCustomerID) REFERENCES Customer(Custid),
    FOREIGN KEY (ToCustomerID) REFERENCES Customer(Custid)
);
GO
PRINT '✓ FundTransfer table created';
GO

-- Step 4: Create Indexes

CREATE INDEX IX_Account_CustomerID ON Account(CustomerID);
CREATE INDEX IX_Account_Status ON Account(Status);
CREATE INDEX IX_SavingsTransaction_SBAccountID ON SavingsTransaction(SBAccountID);
CREATE INDEX IX_LoanTransaction_LnAccountID ON LoanTransaction(Ln_accountid);
CREATE INDEX IX_FundTransfer_FromAccount ON FundTransfer(FromAccountID);
CREATE INDEX IX_FundTransfer_ToAccount ON FundTransfer(ToAccountID);
GO
PRINT '✓ All indexes created';
GO

PRINT '';
PRINT '========================================';
PRINT '✓ ALL TABLES CREATED SUCCESSFULLY!';
PRINT '========================================';
GO

-- ============================================================
-- INSERT DEPARTMENT AND MANAGER DATA
-- ============================================================
-- Run these commands in SQL Server Management Studio (SSMS)
-- ============================================================

USE Banking_Details;
GO

PRINT '========================================';
PRINT 'INSERTING DEPARTMENTS';
PRINT '========================================';
PRINT '';

-- Insert Departments (DEPT01, DEPT02, DEPT03)
INSERT INTO Department (Deptid, Deptname) VALUES 
('DEPT01', 'Deposit Management'),
('DEPT02', 'Loan Management');


PRINT '✓ Departments inserted successfully!';
PRINT '  - DEPT01: Deposit Management';
PRINT '  - DEPT02: Loan Management';
PRINT '  - DEPT03: HR Department';
PRINT '';

-- Verify departments were inserted
SELECT * FROM Department;
PRINT '';

PRINT '========================================';
PRINT 'INSERTING MANAGERS';
PRINT '========================================';
PRINT '';

-- Insert Manager (System Admin)
INSERT INTO Manager (ManagerID, ManagerName, PAN) VALUES 
('MGR001', 'System Admin', 'ADMN0001F');

PRINT '✓ Manager inserted successfully!';
PRINT '  - ID: MGR001';
PRINT '  - Name: System Admin';
PRINT '  - PAN: ADMN0001F';
PRINT '';

-- Verify manager was inserted
SELECT * FROM Manager;
PRINT '';

PRINT '========================================';
PRINT 'INSERTING MANAGER LOGIN CREDENTIALS';
PRINT '========================================';
PRINT '';

-- Insert UserLogin for Manager
INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID) VALUES 
('U001', 'admin', 'Dummy', 'MANAGER', 'MGR001');

PRINT '✓ Manager login created!';
PRINT '  - Username: admin';
PRINT '  - Password: Dummy';
PRINT '  - Role: MANAGER';
PRINT '';

-- Verify login was created
SELECT * FROM UserLogin WHERE Role = 'MANAGER';
PRINT '';

PRINT '========================================';
PRINT 'VERIFICATION COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'Now you can login with:';
PRINT '  Username: admin';
PRINT '  Password: Dummy';
PRINT '';
PRINT 'And use the departments:';
PRINT '  - DEPT01: Deposit Management (for DEPT01 employees)';
PRINT '  - DEPT02: Loan Management (for DEPT02 employees)';
PRINT '  - DEPT03: HR Department (for HR staff)';
PRINT '';

GO

Select * from UserLogin
Select * from FixedDepositAccount
Select * from SavingsAccount

Select * from SavingsTransaction


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
Select * from FDTransaction

SELECT 
    FDAccountID,
    Amount AS Principal,
    MaturityAmount AS 'OLD Maturity (NULL)',
    FD_ROI AS Rate,
    DATEDIFF(MONTH, StartDate, EndDate) AS Tenure
FROM FixedDepositAccount
WHERE MaturityAmount IS NULL OR MaturityAmount = 0;

PRINT '';
PRINT 'Calculating maturity amounts...';

-- FIX: Recalculate all maturity amounts
UPDATE fd
SET MaturityAmount = 
    fd.Amount * 
    POWER(
        (1 + fd.FD_ROI / 100.0), 
        (DATEDIFF(MONTH, fd.StartDate, fd.EndDate) / 12.0)
    )
FROM FixedDepositAccount fd
WHERE (fd.MaturityAmount IS NULL OR fd.MaturityAmount = 0)
    AND fd.Amount IS NOT NULL 
    AND fd.Amount > 0;

PRINT 'Updated: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' FD accounts';
PRINT '';

-- Show AFTER state
SELECT 
    FDAccountID,
    Amount AS Principal,
    MaturityAmount AS 'NEW Maturity ✅',
    FD_ROI AS Rate,
    DATEDIFF(MONTH, StartDate, EndDate) AS Tenure,
    (MaturityAmount - Amount) AS 'Interest Earned'
FROM FixedDepositAccount
ORDER BY FDAccountID;

PRINT '';
PRINT '✅ DONE! Refresh Customer Dashboard to see correct FD balances.';
GO
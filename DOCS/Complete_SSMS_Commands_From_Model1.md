# ?? Complete SSMS/SQL Commands Based on Model1.edmx

## ??? Database: Banking_Details

**Generated from:** `DB/Model1.edmx` (Entity Framework Model)  
**Target:** SQL Server 2012+

---

## ?? Table of Contents

1. [Create Database](#1-create-database)
2. [Create Tables](#2-create-tables)
3. [Foreign Key Relationships](#3-foreign-key-relationships)
4. [Computed Columns](#4-computed-columns)
5. [Indexes & Constraints](#5-indexes--constraints)
6. [Sample Data Insert](#6-sample-data-insert)
7. [Useful Queries](#7-useful-queries)
8. [Maintenance Commands](#8-maintenance-commands)

---

## 1. Create Database

```sql
-- Create Database
CREATE DATABASE Banking_Details;
GO

USE Banking_Details;
GO
```

---

## 2. Create Tables

### 2.1 Department Table

```sql
CREATE TABLE Department (
    Deptid CHAR(6) PRIMARY KEY,
    Deptname VARCHAR(20) NOT NULL
);
```

**Purpose:** Stores department information (DEPT01, DEPT02, DEPT03)

---

### 2.2 Manager Table

```sql
CREATE TABLE Manager (
    ManagerID VARCHAR(8) PRIMARY KEY,
    ManagerName VARCHAR(50) NOT NULL,
    PAN VARCHAR(10) NULL
);
```

**Purpose:** Stores manager information

---

### 2.3 Customer Table

```sql
CREATE TABLE Customer (
    Custid CHAR(8) PRIMARY KEY,
    Custname VARCHAR(20) NOT NULL,
    DOB DATE NULL,
    Pan VARCHAR(10) NULL,
    Address VARCHAR(100) NULL,
    PhoneNumber VARCHAR(15) NULL
);
```

**Purpose:** Stores customer information (CustID format: MLA00001)

---

### 2.4 Employee Table

```sql
CREATE TABLE Employee (
    Empid VARCHAR(20) PRIMARY KEY,
    EmployeeName VARCHAR(20) NOT NULL,
    DeptId CHAR(6) NULL,
    Pan VARCHAR(10) NULL,
    CONSTRAINT FK__Employee__DeptId__2180FB33 
        FOREIGN KEY (DeptId) REFERENCES Department(Deptid)
);
```

**Purpose:** Stores employee information (EmpID format: 2600001)

---

### 2.5 UserLogin Table

```sql
CREATE TABLE UserLogin (
    UserID VARCHAR(20) PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(15) NULL,
    ReferenceID VARCHAR(8) NULL
);
```

**Purpose:** Stores login credentials for all users (Manager, Employee, Customer)

---

### 2.6 Account Table (Master)

```sql
CREATE TABLE Account (
    AccountID CHAR(7) PRIMARY KEY,
    AccountType VARCHAR(15) NULL,
    CustomerID CHAR(8) NULL,
    OpenedBy VARCHAR(20) NULL,
    OpenedByRole VARCHAR(10) NULL,
    OpenDate DATE NOT NULL,
    Status VARCHAR(10) NULL,
    ClosedDate DATE NULL,
    CONSTRAINT FK__Account__Custome__2B0A656D 
        FOREIGN KEY (CustomerID) REFERENCES Customer(Custid)
);
```

**Purpose:** Master table for all accounts (Savings, FD, Loan)

---

### 2.7 SavingsAccount Table

```sql
CREATE TABLE SavingsAccount (
    SBAccountID CHAR(7) PRIMARY KEY,
    Customerid CHAR(8) NULL,
    Balance SMALLMONEY NULL,
    CONSTRAINT FK__SavingsAc__SBAcc__30C33EC3 
        FOREIGN KEY (SBAccountID) REFERENCES Account(AccountID),
    CONSTRAINT FK__SavingsAc__Custo__31B762FC 
        FOREIGN KEY (Customerid) REFERENCES Customer(Custid)
);
```

**Purpose:** Stores savings account details (SBAccountID format: SB00001)

---

### 2.8 FixedDepositAccount Table

```sql
CREATE TABLE FixedDepositAccount (
    FDAccountID CHAR(7) PRIMARY KEY,
    CustomerID CHAR(8) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    FD_ROI DECIMAL(4,2) NOT NULL,
    Amount DECIMAL(12,2) NULL,
    MaturityAmount AS (Amount * POWER((1 + FD_ROI/100), DATEDIFF(MONTH, StartDate, EndDate)/12.0)) PERSISTED,
    CONSTRAINT FK__FixedDepo__FDAcc__4E53A1AA 
        FOREIGN KEY (FDAccountID) REFERENCES Account(AccountID),
    CONSTRAINT FK__FixedDepo__Custo__4F47C5E3 
        FOREIGN KEY (CustomerID) REFERENCES Customer(Custid)
);
```

**Purpose:** Stores fixed deposit account details (FDAccountID format: FD00001)

**Note:** `MaturityAmount` is a **computed column** that calculates maturity based on FD_ROI and tenure

---

### 2.9 LoanAccount Table

```sql
CREATE TABLE LoanAccount (
    Ln_accountid CHAR(7) PRIMARY KEY,
    Customer CHAR(8) NOT NULL,
    loan_amount DECIMAL(12,2) NULL,
    Start_date DATE NOT NULL,
    Tenure INT NOT NULL,
    Ln_roi DECIMAL(4,2) NOT NULL,
    Emi DECIMAL(12,2) NULL,
    CONSTRAINT FK_LoanAccount_Account 
        FOREIGN KEY (Ln_accountid) REFERENCES Account(AccountID),
    CONSTRAINT FK_LoanAccount_Customer 
        FOREIGN KEY (Customer) REFERENCES Customer(Custid)
);
```

**Purpose:** Stores loan account details (Ln_accountid format: LA00001)

---

### 2.10 SavingsTransaction Table

```sql
CREATE TABLE SavingsTransaction (
    Transactionid INT IDENTITY(1,1) PRIMARY KEY,
    SBAccountID CHAR(7) NOT NULL,
    Transationdate DATETIME NULL,
    Transactiontype VARCHAR(10) NULL,
    Amount DECIMAL(18,2) NULL,
    CONSTRAINT FK_SavingsTransaction_SavingsAccount 
        FOREIGN KEY (SBAccountID) REFERENCES SavingsAccount(SBAccountID)
);
```

**Purpose:** Stores all transactions for savings accounts (Deposits, Withdrawals, Transfers)

**Transaction Types:**
- `DEPOSIT`
- `WITHDRAW`
- `TRANSFER_DEBIT`
- `TRANSFER_CREDIT`

---

### 2.11 FDTransaction Table

```sql
CREATE TABLE FDTransaction (
    TransactionID INT PRIMARY KEY,
    FDAccountID CHAR(7) NULL,
    TransactionType VARCHAR(15) NULL,
    Amount SMALLMONEY NOT NULL,
    TransactionDate DATETIME NULL,
    CONSTRAINT FK__FDTransac__FDAcc__540C7B00 
        FOREIGN KEY (FDAccountID) REFERENCES FixedDepositAccount(FDAccountID)
);
```

**Purpose:** Stores fixed deposit transactions

---

### 2.12 LoanTransaction Table

```sql
CREATE TABLE LoanTransaction (
    Transactionno INT IDENTITY(1,1) PRIMARY KEY,
    Ln_accountid CHAR(7) NOT NULL,
    Emidate DATETIME NULL,
    Amount DECIMAL(12,2) NULL,
    Outstanding DECIMAL(12,2) NULL,
    PaymentType VARCHAR(20) NULL,
    PaidBy CHAR(8) NULL,
    CONSTRAINT FK_LoanTransaction_LoanAccount 
        FOREIGN KEY (Ln_accountid) REFERENCES LoanAccount(Ln_accountid)
);
```

**Purpose:** Stores loan EMI payments

**Payment Types:**
- `EMI` - Regular monthly payment
- `PART_PAYMENT` - Extra payment towards principal
- `FULL_CLOSURE` - Complete loan closure

---

### 2.13 FundTransfer Table

```sql
CREATE TABLE FundTransfer (
    TransferID INT IDENTITY(1,1) PRIMARY KEY,
    FromAccountID CHAR(7) NOT NULL,
    ToAccountID CHAR(7) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    TransferDate DATETIME NOT NULL,
    FromCustomerID CHAR(8) NOT NULL,
    ToCustomerID CHAR(8) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    Remarks VARCHAR(200) NULL,
    CONSTRAINT FK_FundTransfer_FromAccount 
        FOREIGN KEY (FromAccountID) REFERENCES SavingsAccount(SBAccountID),
    CONSTRAINT FK_FundTransfer_ToAccount 
        FOREIGN KEY (ToAccountID) REFERENCES SavingsAccount(SBAccountID),
    CONSTRAINT FK_FundTransfer_FromCustomer 
        FOREIGN KEY (FromCustomerID) REFERENCES Customer(Custid),
    CONSTRAINT FK_FundTransfer_ToCustomer 
        FOREIGN KEY (ToCustomerID) REFERENCES Customer(Custid)
);
```

**Purpose:** Stores fund transfers between savings accounts

---

## 3. Foreign Key Relationships

### 3.1 Visual Relationship Summary

```
Department
    ??? Employee (DeptId)

Customer
    ??? Account (CustomerID)
    ??? SavingsAccount (Customerid)
    ??? FixedDepositAccount (CustomerID)
    ??? LoanAccount (Customer)
    ??? FundTransfer (FromCustomerID)
    ??? FundTransfer (ToCustomerID)

Account
    ??? SavingsAccount (SBAccountID)
    ??? FixedDepositAccount (FDAccountID)
    ??? LoanAccount (Ln_accountid)

SavingsAccount
    ??? SavingsTransaction (SBAccountID)
    ??? FundTransfer (FromAccountID)
    ??? FundTransfer (ToAccountID)

FixedDepositAccount
    ??? FDTransaction (FDAccountID)

LoanAccount
    ??? LoanTransaction (Ln_accountid)
```

---

## 4. Computed Columns

### 4.1 MaturityAmount in FixedDepositAccount

```sql
-- Computed column formula
MaturityAmount = Amount * POWER((1 + FD_ROI/100), DATEDIFF(MONTH, StartDate, EndDate)/12.0)
```

**Example Calculation:**
- Amount: ?100,000
- FD_ROI: 7% (0.07)
- Tenure: 24 months (2 years)
- MaturityAmount = 100000 × (1 + 0.07)^2 = ?114,490

---

## 5. Indexes & Constraints

### 5.1 Primary Keys (Already created with tables)

```sql
-- All tables have PRIMARY KEY constraints defined
```

### 5.2 Add Unique Constraints

```sql
-- Ensure unique PAN for Customers
ALTER TABLE Customer 
ADD CONSTRAINT UQ_Customer_Pan UNIQUE (Pan);

-- Ensure unique PAN for Employees
ALTER TABLE Employee 
ADD CONSTRAINT UQ_Employee_Pan UNIQUE (Pan);

-- Ensure unique PAN for Managers
ALTER TABLE Manager 
ADD CONSTRAINT UQ_Manager_Pan UNIQUE (PAN);

-- Ensure unique username in UserLogin
ALTER TABLE UserLogin 
ADD CONSTRAINT UQ_UserLogin_UserName UNIQUE (UserName);
```

### 5.3 Add Check Constraints

```sql
-- Account Status must be OPEN or CLOSED
ALTER TABLE Account 
ADD CONSTRAINT CK_Account_Status 
CHECK (Status IN ('OPEN', 'CLOSED'));

-- Account Type must be SAVING, FIXED-DEPOSIT, or LOAN
ALTER TABLE Account 
ADD CONSTRAINT CK_Account_Type 
CHECK (AccountType IN ('SAVING', 'FIXED-DEPOSIT', 'LOAN'));

-- SavingsTransaction Type
ALTER TABLE SavingsTransaction 
ADD CONSTRAINT CK_SavingsTransaction_Type 
CHECK (Transactiontype IN ('DEPOSIT', 'WITHDRAW', 'TRANSFER_DEBIT', 'TRANSFER_CREDIT', 'INITIAL DEPOSIT'));

-- FundTransfer Status
ALTER TABLE FundTransfer 
ADD CONSTRAINT CK_FundTransfer_Status 
CHECK (Status IN ('SUCCESS', 'FAILED', 'PENDING'));

-- Loan Payment Type
ALTER TABLE LoanTransaction 
ADD CONSTRAINT CK_LoanTransaction_PaymentType 
CHECK (PaymentType IN ('EMI', 'PART_PAYMENT', 'FULL_CLOSURE'));

-- UserLogin Role
ALTER TABLE UserLogin 
ADD CONSTRAINT CK_UserLogin_Role 
CHECK (Role IN ('MANAGER', 'EMPLOYEE', 'CUSTOMER'));
```

### 5.4 Add Check Constraints for Positive Amounts

```sql
-- Ensure positive balances
ALTER TABLE SavingsAccount 
ADD CONSTRAINT CK_SavingsAccount_Balance_Positive 
CHECK (Balance >= 0);

-- Ensure positive FD amounts
ALTER TABLE FixedDepositAccount 
ADD CONSTRAINT CK_FD_Amount_Positive 
CHECK (Amount >= 10000); -- Min ?10,000

-- Ensure positive loan amounts
ALTER TABLE LoanAccount 
ADD CONSTRAINT CK_Loan_Amount_Positive 
CHECK (loan_amount >= 10000); -- Min ?10,000

-- Ensure positive transaction amounts
ALTER TABLE SavingsTransaction 
ADD CONSTRAINT CK_SavingsTransaction_Amount_Positive 
CHECK (Amount > 0);

ALTER TABLE FundTransfer 
ADD CONSTRAINT CK_FundTransfer_Amount_Positive 
CHECK (Amount >= 100 AND Amount <= 100000); -- Min ?100, Max ?100,000
```

---

## 6. Sample Data Insert

### 6.1 Insert Departments

```sql
INSERT INTO Department (Deptid, Deptname) VALUES
('DEPT01', 'Deposit Management'),
('DEPT02', 'Loan Management'),
('DEPT03', 'HR Department');
```

### 6.2 Insert Manager

```sql
INSERT INTO Manager (ManagerID, ManagerName, PAN) VALUES
('MGR001', 'Admin Manager', 'ADMIN12345');
```

### 6.3 Insert Manager Login

```sql
-- Password: "Dummy" (hashed)
INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID) VALUES
('admin', 'admin', '...hash...', 'MANAGER', 'MGR001');
```

### 6.4 Insert Sample Employee

```sql
-- Insert Employee
INSERT INTO Employee (Empid, EmployeeName, DeptId, Pan) VALUES
('2600001', 'John Smith', 'DEPT01', 'EMPAN12345');

-- Insert Employee Login
INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID) VALUES
('emp_2600001', 'john_smith', '...hash...', 'EMPLOYEE', '2600001');
```

### 6.5 Insert Sample Customer

```sql
-- Insert Customer
INSERT INTO Customer (Custid, Custname, DOB, Pan, Address, PhoneNumber) VALUES
('MLA00001', 'Rajesh Kumar', '1990-05-15', 'ABCDE1234F', '123 MG Road, Bangalore', '9876543210');

-- Insert Customer Login
INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID) VALUES
('cust_MLA00001', 'rajesh_kumar', '...hash...', 'CUSTOMER', 'MLA00001');
```

### 6.6 Insert Sample Savings Account

```sql
-- Insert in Account (master)
INSERT INTO Account (AccountID, AccountType, CustomerID, OpenedBy, OpenedByRole, OpenDate, Status) VALUES
('SB00001', 'SAVING', 'MLA00001', '2600001', 'EMPLOYEE', GETDATE(), 'OPEN');

-- Insert in SavingsAccount
INSERT INTO SavingsAccount (SBAccountID, Customerid, Balance) VALUES
('SB00001', 'MLA00001', 1000.00);

-- Insert initial deposit transaction
INSERT INTO SavingsTransaction (SBAccountID, Transationdate, Transactiontype, Amount) VALUES
('SB00001', GETDATE(), 'INITIAL DEPOSIT', 1000.00);
```

---

## 7. Useful Queries

### 7.1 Get Customer with All Accounts

```sql
SELECT 
    c.Custid,
    c.Custname,
    a.AccountID,
    a.AccountType,
    a.Status,
    CASE 
        WHEN a.AccountType = 'SAVING' THEN CAST(sa.Balance AS VARCHAR)
        WHEN a.AccountType = 'FIXED-DEPOSIT' THEN CAST(fd.MaturityAmount AS VARCHAR)
        WHEN a.AccountType = 'LOAN' THEN CAST(la.Emi AS VARCHAR)
    END AS 'Amount/EMI'
FROM Customer c
LEFT JOIN Account a ON c.Custid = a.CustomerID
LEFT JOIN SavingsAccount sa ON a.AccountID = sa.SBAccountID
LEFT JOIN FixedDepositAccount fd ON a.AccountID = fd.FDAccountID
LEFT JOIN LoanAccount la ON a.AccountID = la.Ln_accountid
WHERE c.Custid = 'MLA00001'
ORDER BY a.OpenDate DESC;
```

### 7.2 Get Savings Account Transactions

```sql
SELECT 
    st.Transactionid,
    st.SBAccountID,
    st.Transationdate,
    st.Transactiontype,
    st.Amount,
    sa.Balance AS CurrentBalance
FROM SavingsTransaction st
JOIN SavingsAccount sa ON st.SBAccountID = sa.SBAccountID
WHERE st.SBAccountID = 'SB00001'
ORDER BY st.Transationdate DESC;
```

### 7.3 Get Loan Account Details with Outstanding

```sql
SELECT 
    la.Ln_accountid,
    la.Customer,
    c.Custname,
    la.loan_amount,
    la.Start_date,
    la.Tenure,
    la.Ln_roi,
    la.Emi,
    ISNULL(lt.Outstanding, la.loan_amount) AS CurrentOutstanding
FROM LoanAccount la
JOIN Customer c ON la.Customer = c.Custid
LEFT JOIN (
    SELECT 
        Ln_accountid, 
        Outstanding,
        ROW_NUMBER() OVER (PARTITION BY Ln_accountid ORDER BY Emidate DESC) AS rn
    FROM LoanTransaction
) lt ON la.Ln_accountid = lt.Ln_accountid AND lt.rn = 1
WHERE la.Ln_accountid = 'LA00001';
```

### 7.4 Get All Active Accounts

```sql
SELECT 
    a.AccountID,
    a.AccountType,
    c.Custname,
    a.OpenDate,
    a.Status
FROM Account a
JOIN Customer c ON a.CustomerID = c.Custid
WHERE a.Status = 'OPEN'
ORDER BY a.OpenDate DESC;
```

### 7.5 Get Fund Transfers for Customer

```sql
SELECT 
    ft.TransferID,
    ft.FromAccountID,
    ft.ToAccountID,
    ft.Amount,
    ft.TransferDate,
    ft.Status,
    ft.Remarks,
    c1.Custname AS FromCustomer,
    c2.Custname AS ToCustomer
FROM FundTransfer ft
JOIN Customer c1 ON ft.FromCustomerID = c1.Custid
JOIN Customer c2 ON ft.ToCustomerID = c2.Custid
WHERE ft.FromCustomerID = 'MLA00001' OR ft.ToCustomerID = 'MLA00001'
ORDER BY ft.TransferDate DESC;
```

### 7.6 Get Employee with Department

```sql
SELECT 
    e.Empid,
    e.EmployeeName,
    d.Deptname,
    e.Pan
FROM Employee e
LEFT JOIN Department d ON e.DeptId = d.Deptid
ORDER BY e.Empid;
```

### 7.7 Get Statistics

```sql
-- Total Customers
SELECT COUNT(*) AS TotalCustomers FROM Customer;

-- Total Employees
SELECT COUNT(*) AS TotalEmployees FROM Employee;

-- Total Active Accounts
SELECT COUNT(*) AS TotalActiveAccounts FROM Account WHERE Status = 'OPEN';

-- Total Savings Balance
SELECT SUM(Balance) AS TotalSavingsBalance FROM SavingsAccount;

-- Total Loan Outstanding
SELECT SUM(loan_amount) AS TotalLoanAmount FROM LoanAccount
WHERE Ln_accountid IN (SELECT AccountID FROM Account WHERE Status = 'OPEN');
```

---

## 8. Maintenance Commands

### 8.1 View All Tables

```sql
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

### 8.2 View All Foreign Keys

```sql
SELECT 
    fk.name AS FK_Name,
    tp.name AS Parent_Table,
    cp.name AS Parent_Column,
    tr.name AS Referenced_Table,
    cr.name AS Referenced_Column
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
JOIN sys.tables AS tp ON fkc.parent_object_id = tp.object_id
JOIN sys.columns AS cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
JOIN sys.tables AS tr ON fkc.referenced_object_id = tr.object_id
JOIN sys.columns AS cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
ORDER BY tp.name, fk.name;
```

### 8.3 View All Check Constraints

```sql
SELECT 
    cc.name AS Constraint_Name,
    t.name AS Table_Name,
    cc.definition AS Check_Condition
FROM sys.check_constraints AS cc
JOIN sys.tables AS t ON cc.parent_object_id = t.object_id
ORDER BY t.name, cc.name;
```

### 8.4 Delete All Data (For Testing)

```sql
-- Disable all foreign key constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Delete data from all tables
EXEC sp_MSforeachtable 'DELETE FROM ?';

-- Re-enable all foreign key constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL';

-- Reset identity columns
EXEC sp_MSforeachtable 'IF OBJECTPROPERTY(OBJECT_ID(''?''), ''TableHasIdentity'') = 1 DBCC CHECKIDENT(''?'', RESEED, 0)';
```

### 8.5 Backup Database

```sql
BACKUP DATABASE Banking_Details 
TO DISK = 'C:\Backup\Banking_Details.bak'
WITH FORMAT, MEDIANAME = 'Banking_Details_Backup', NAME = 'Full Backup of Banking_Details';
```

### 8.6 Restore Database

```sql
RESTORE DATABASE Banking_Details 
FROM DISK = 'C:\Backup\Banking_Details.bak'
WITH REPLACE;
```

---

## 9. Column Data Types Summary

| Table | Column | Type | Max Length | Nullable | Notes |
|-------|--------|------|------------|----------|-------|
| Department | Deptid | CHAR | 6 | NO | PK |
| Department | Deptname | VARCHAR | 20 | NO | |
| Manager | ManagerID | VARCHAR | 8 | NO | PK |
| Manager | ManagerName | VARCHAR | 50 | NO | |
| Manager | PAN | VARCHAR | 10 | YES | |
| Customer | Custid | CHAR | 8 | NO | PK, Format: MLA00001 |
| Customer | Custname | VARCHAR | 20 | NO | |
| Customer | DOB | DATE | - | YES | |
| Customer | Pan | VARCHAR | 10 | YES | Format: ABCDE1234F |
| Customer | Address | VARCHAR | 100 | YES | |
| Customer | PhoneNumber | VARCHAR | 15 | YES | |
| Employee | Empid | VARCHAR | 20 | NO | PK, Format: 2600001 |
| Employee | EmployeeName | VARCHAR | 20 | NO | |
| Employee | DeptId | CHAR | 6 | YES | FK to Department |
| Employee | Pan | VARCHAR | 10 | YES | |
| UserLogin | UserID | VARCHAR | 20 | NO | PK |
| UserLogin | UserName | VARCHAR | 50 | NO | Unique |
| UserLogin | PasswordHash | VARCHAR | 255 | NO | Hashed password |
| UserLogin | Role | VARCHAR | 15 | YES | MANAGER/EMPLOYEE/CUSTOMER |
| UserLogin | ReferenceID | VARCHAR | 8 | YES | Points to Manager/Employee/Customer ID |
| Account | AccountID | CHAR | 7 | NO | PK, SB/FD/LA + 5 digits |
| Account | AccountType | VARCHAR | 15 | YES | SAVING/FIXED-DEPOSIT/LOAN |
| Account | CustomerID | CHAR | 8 | YES | FK to Customer |
| Account | OpenedBy | VARCHAR | 20 | YES | Manager/Employee ID |
| Account | OpenedByRole | VARCHAR | 10 | YES | MANAGER/EMPLOYEE |
| Account | OpenDate | DATE | - | NO | |
| Account | Status | VARCHAR | 10 | YES | OPEN/CLOSED |
| Account | ClosedDate | DATE | - | YES | |
| SavingsAccount | SBAccountID | CHAR | 7 | NO | PK, FK to Account |
| SavingsAccount | Customerid | CHAR | 8 | YES | FK to Customer |
| SavingsAccount | Balance | SMALLMONEY | - | YES | Precision: 10,4 |
| FixedDepositAccount | FDAccountID | CHAR | 7 | NO | PK, FK to Account |
| FixedDepositAccount | CustomerID | CHAR | 8 | YES | FK to Customer |
| FixedDepositAccount | StartDate | DATE | - | NO | |
| FixedDepositAccount | EndDate | DATE | - | NO | |
| FixedDepositAccount | FD_ROI | DECIMAL | 4,2 | NO | Interest rate (e.g., 7.00%) |
| FixedDepositAccount | Amount | DECIMAL | 12,2 | YES | Principal amount |
| FixedDepositAccount | MaturityAmount | DECIMAL | 37,11 | COMPUTED | Auto-calculated |
| LoanAccount | Ln_accountid | CHAR | 7 | NO | PK, FK to Account |
| LoanAccount | Customer | CHAR | 8 | NO | FK to Customer |
| LoanAccount | loan_amount | DECIMAL | 12,2 | YES | Loan principal |
| LoanAccount | Start_date | DATE | - | NO | |
| LoanAccount | Tenure | INT | - | NO | In months |
| LoanAccount | Ln_roi | DECIMAL | 4,2 | NO | Interest rate |
| LoanAccount | Emi | DECIMAL | 12,2 | YES | Monthly EMI |
| SavingsTransaction | Transactionid | INT | - | NO | PK, IDENTITY |
| SavingsTransaction | SBAccountID | CHAR | 7 | NO | FK to SavingsAccount |
| SavingsTransaction | Transationdate | DATETIME | - | YES | |
| SavingsTransaction | Transactiontype | VARCHAR | 10 | YES | DEPOSIT/WITHDRAW/etc |
| SavingsTransaction | Amount | DECIMAL | 18,2 | YES | |
| FDTransaction | TransactionID | INT | - | NO | PK |
| FDTransaction | FDAccountID | CHAR | 7 | YES | FK to FixedDepositAccount |
| FDTransaction | TransactionType | VARCHAR | 15 | YES | |
| FDTransaction | Amount | SMALLMONEY | - | NO | Precision: 10,4 |
| FDTransaction | TransactionDate | DATETIME | - | YES | |
| LoanTransaction | Transactionno | INT | - | NO | PK, IDENTITY |
| LoanTransaction | Ln_accountid | CHAR | 7 | NO | FK to LoanAccount |
| LoanTransaction | Emidate | DATETIME | - | YES | |
| LoanTransaction | Amount | DECIMAL | 12,2 | YES | Payment amount |
| LoanTransaction | Outstanding | DECIMAL | 12,2 | YES | Remaining loan |
| LoanTransaction | PaymentType | VARCHAR | 20 | YES | EMI/PART_PAYMENT/FULL_CLOSURE |
| LoanTransaction | PaidBy | CHAR | 8 | YES | Customer ID |
| FundTransfer | TransferID | INT | - | NO | PK, IDENTITY |
| FundTransfer | FromAccountID | CHAR | 7 | NO | FK to SavingsAccount |
| FundTransfer | ToAccountID | CHAR | 7 | NO | FK to SavingsAccount |
| FundTransfer | Amount | DECIMAL | 12,2 | NO | Transfer amount |
| FundTransfer | TransferDate | DATETIME | - | NO | |
| FundTransfer | FromCustomerID | CHAR | 8 | NO | FK to Customer |
| FundTransfer | ToCustomerID | CHAR | 8 | NO | FK to Customer |
| FundTransfer | Status | VARCHAR | 20 | NO | SUCCESS/FAILED/PENDING |
| FundTransfer | Remarks | VARCHAR | 200 | YES | Optional note |

---

## 10. ID Formats & Auto-Generation

| Entity | ID Format | Example | Generation Logic |
|--------|-----------|---------|------------------|
| Customer | MLA + 5 digits | MLA00001 | Auto-increment from last Custid |
| Employee | 26 + 5 digits | 2600001 | Auto-increment from last Empid |
| Manager | MGR + 3 digits | MGR001 | Manual/Auto-increment |
| Savings Account | SB + 5 digits | SB00001 | Auto-increment from last SBAccountID |
| FD Account | FD + 5 digits | FD00001 | Auto-increment from last FDAccountID |
| Loan Account | LA + 5 digits | LA00001 | Auto-increment from last Ln_accountid |
| UserLogin | Auto-generated | admin, cust_MLA00001 | Based on role and reference ID |

---

## 11. Complete Table Creation Script (Copy-Paste Ready)

```sql
USE Banking_Details;
GO

-- 1. Department
CREATE TABLE Department (
    Deptid CHAR(6) PRIMARY KEY,
    Deptname VARCHAR(20) NOT NULL
);

-- 2. Manager
CREATE TABLE Manager (
    ManagerID VARCHAR(8) PRIMARY KEY,
    ManagerName VARCHAR(50) NOT NULL,
    PAN VARCHAR(10) NULL
);

-- 3. Customer
CREATE TABLE Customer (
    Custid CHAR(8) PRIMARY KEY,
    Custname VARCHAR(20) NOT NULL,
    DOB DATE NULL,
    Pan VARCHAR(10) NULL,
    Address VARCHAR(100) NULL,
    PhoneNumber VARCHAR(15) NULL
);

-- 4. Employee
CREATE TABLE Employee (
    Empid VARCHAR(20) PRIMARY KEY,
    EmployeeName VARCHAR(20) NOT NULL,
    DeptId CHAR(6) NULL,
    Pan VARCHAR(10) NULL,
    CONSTRAINT FK__Employee__DeptId__2180FB33 
        FOREIGN KEY (DeptId) REFERENCES Department(Deptid)
);

-- 5. UserLogin
CREATE TABLE UserLogin (
    UserID VARCHAR(20) PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(15) NULL,
    ReferenceID VARCHAR(8) NULL
);

-- 6. Account (Master)
CREATE TABLE Account (
    AccountID CHAR(7) PRIMARY KEY,
    AccountType VARCHAR(15) NULL,
    CustomerID CHAR(8) NULL,
    OpenedBy VARCHAR(20) NULL,
    OpenedByRole VARCHAR(10) NULL,
    OpenDate DATE NOT NULL,
    Status VARCHAR(10) NULL,
    ClosedDate DATE NULL,
    CONSTRAINT FK__Account__Custome__2B0A656D 
        FOREIGN KEY (CustomerID) REFERENCES Customer(Custid)
);

-- 7. SavingsAccount
CREATE TABLE SavingsAccount (
    SBAccountID CHAR(7) PRIMARY KEY,
    Customerid CHAR(8) NULL,
    Balance SMALLMONEY NULL,
    CONSTRAINT FK__SavingsAc__SBAcc__30C33EC3 
        FOREIGN KEY (SBAccountID) REFERENCES Account(AccountID),
    CONSTRAINT FK__SavingsAc__Custo__31B762FC 
        FOREIGN KEY (Customerid) REFERENCES Customer(Custid)
);

-- 8. FixedDepositAccount
CREATE TABLE FixedDepositAccount (
    FDAccountID CHAR(7) PRIMARY KEY,
    CustomerID CHAR(8) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    FD_ROI DECIMAL(4,2) NOT NULL,
    Amount DECIMAL(12,2) NULL,
    MaturityAmount AS (Amount * POWER((1 + FD_ROI/100), DATEDIFF(MONTH, StartDate, EndDate)/12.0)) PERSISTED,
    CONSTRAINT FK__FixedDepo__FDAcc__4E53A1AA 
        FOREIGN KEY (FDAccountID) REFERENCES Account(AccountID),
    CONSTRAINT FK__FixedDepo__Custo__4F47C5E3 
        FOREIGN KEY (CustomerID) REFERENCES Customer(Custid)
);

-- 9. LoanAccount
CREATE TABLE LoanAccount (
    Ln_accountid CHAR(7) PRIMARY KEY,
    Customer CHAR(8) NOT NULL,
    loan_amount DECIMAL(12,2) NULL,
    Start_date DATE NOT NULL,
    Tenure INT NOT NULL,
    Ln_roi DECIMAL(4,2) NOT NULL,
    Emi DECIMAL(12,2) NULL,
    CONSTRAINT FK_LoanAccount_Account 
        FOREIGN KEY (Ln_accountid) REFERENCES Account(AccountID),
    CONSTRAINT FK_LoanAccount_Customer 
        FOREIGN KEY (Customer) REFERENCES Customer(Custid)
);

-- 10. SavingsTransaction
CREATE TABLE SavingsTransaction (
    Transactionid INT IDENTITY(1,1) PRIMARY KEY,
    SBAccountID CHAR(7) NOT NULL,
    Transationdate DATETIME NULL,
    Transactiontype VARCHAR(10) NULL,
    Amount DECIMAL(18,2) NULL,
    CONSTRAINT FK_SavingsTransaction_SavingsAccount 
        FOREIGN KEY (SBAccountID) REFERENCES SavingsAccount(SBAccountID)
);

-- 11. FDTransaction
CREATE TABLE FDTransaction (
    TransactionID INT PRIMARY KEY,
    FDAccountID CHAR(7) NULL,
    TransactionType VARCHAR(15) NULL,
    Amount SMALLMONEY NOT NULL,
    TransactionDate DATETIME NULL,
    CONSTRAINT FK__FDTransac__FDAcc__540C7B00 
        FOREIGN KEY (FDAccountID) REFERENCES FixedDepositAccount(FDAccountID)
);

-- 12. LoanTransaction
CREATE TABLE LoanTransaction (
    Transactionno INT IDENTITY(1,1) PRIMARY KEY,
    Ln_accountid CHAR(7) NOT NULL,
    Emidate DATETIME NULL,
    Amount DECIMAL(12,2) NULL,
    Outstanding DECIMAL(12,2) NULL,
    PaymentType VARCHAR(20) NULL,
    PaidBy CHAR(8) NULL,
    CONSTRAINT FK_LoanTransaction_LoanAccount 
        FOREIGN KEY (Ln_accountid) REFERENCES LoanAccount(Ln_accountid)
);

-- 13. FundTransfer
CREATE TABLE FundTransfer (
    TransferID INT IDENTITY(1,1) PRIMARY KEY,
    FromAccountID CHAR(7) NOT NULL,
    ToAccountID CHAR(7) NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    TransferDate DATETIME NOT NULL,
    FromCustomerID CHAR(8) NOT NULL,
    ToCustomerID CHAR(8) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    Remarks VARCHAR(200) NULL,
    CONSTRAINT FK_FundTransfer_FromAccount 
        FOREIGN KEY (FromAccountID) REFERENCES SavingsAccount(SBAccountID),
    CONSTRAINT FK_FundTransfer_ToAccount 
        FOREIGN KEY (ToAccountID) REFERENCES SavingsAccount(SBAccountID),
    CONSTRAINT FK_FundTransfer_FromCustomer 
        FOREIGN KEY (FromCustomerID) REFERENCES Customer(Custid),
    CONSTRAINT FK_FundTransfer_ToCustomer 
        FOREIGN KEY (ToCustomerID) REFERENCES Customer(Custid)
);
GO
```

---

## ?? Summary

This document contains **all SQL commands** derived from the `Model1.edmx` Entity Framework model, including:

? **13 Tables** with complete structure  
? **18 Foreign Key Relationships**  
? **1 Computed Column** (MaturityAmount)  
? **Check Constraints** for data validation  
? **Unique Constraints** for PAN numbers  
? **Sample Data Inserts**  
? **Useful Queries** for common operations  
? **Maintenance Commands**  

**Total Commands:** 100+ SQL statements

---

**Generated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Source:** Model1.edmx  
**Database:** Banking_Details  
**Target:** SQL Server 2012+

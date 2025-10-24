# ?? Quick Reference: SSMS Commands Summary

## ?? Essential SQL Commands for Banking_Details Database

**Full Documentation:** `DOCS/Complete_SSMS_Commands_From_Model1.md`

---

## ?? Quick Start (Copy & Paste)

### 1. Create Database

```sql
CREATE DATABASE Banking_Details;
GO
USE Banking_Details;
GO
```

### 2. Create All Tables (Copy-Paste Ready)

```sql
-- Execute this entire block to create all 13 tables with relationships
USE Banking_Details;
GO

CREATE TABLE Department (Deptid CHAR(6) PRIMARY KEY, Deptname VARCHAR(20) NOT NULL);
CREATE TABLE Manager (ManagerID VARCHAR(8) PRIMARY KEY, ManagerName VARCHAR(50) NOT NULL, PAN VARCHAR(10) NULL);
CREATE TABLE Customer (Custid CHAR(8) PRIMARY KEY, Custname VARCHAR(20) NOT NULL, DOB DATE NULL, Pan VARCHAR(10) NULL, Address VARCHAR(100) NULL, PhoneNumber VARCHAR(15) NULL);
CREATE TABLE Employee (Empid VARCHAR(20) PRIMARY KEY, EmployeeName VARCHAR(20) NOT NULL, DeptId CHAR(6) NULL, Pan VARCHAR(10) NULL, CONSTRAINT FK__Employee__DeptId__2180FB33 FOREIGN KEY (DeptId) REFERENCES Department(Deptid));
CREATE TABLE UserLogin (UserID VARCHAR(20) PRIMARY KEY, UserName VARCHAR(50) NOT NULL, PasswordHash VARCHAR(255) NOT NULL, Role VARCHAR(15) NULL, ReferenceID VARCHAR(8) NULL);
CREATE TABLE Account (AccountID CHAR(7) PRIMARY KEY, AccountType VARCHAR(15) NULL, CustomerID CHAR(8) NULL, OpenedBy VARCHAR(20) NULL, OpenedByRole VARCHAR(10) NULL, OpenDate DATE NOT NULL, Status VARCHAR(10) NULL, ClosedDate DATE NULL, CONSTRAINT FK__Account__Custome__2B0A656D FOREIGN KEY (CustomerID) REFERENCES Customer(Custid));
CREATE TABLE SavingsAccount (SBAccountID CHAR(7) PRIMARY KEY, Customerid CHAR(8) NULL, Balance SMALLMONEY NULL, CONSTRAINT FK__SavingsAc__SBAcc__30C33EC3 FOREIGN KEY (SBAccountID) REFERENCES Account(AccountID), CONSTRAINT FK__SavingsAc__Custo__31B762FC FOREIGN KEY (Customerid) REFERENCES Customer(Custid));
CREATE TABLE FixedDepositAccount (FDAccountID CHAR(7) PRIMARY KEY, CustomerID CHAR(8) NULL, StartDate DATE NOT NULL, EndDate DATE NOT NULL, FD_ROI DECIMAL(4,2) NOT NULL, Amount DECIMAL(12,2) NULL, MaturityAmount AS (Amount * POWER((1 + FD_ROI/100), DATEDIFF(MONTH, StartDate, EndDate)/12.0)) PERSISTED, CONSTRAINT FK__FixedDepo__FDAcc__4E53A1AA FOREIGN KEY (FDAccountID) REFERENCES Account(AccountID), CONSTRAINT FK__FixedDepo__Custo__4F47C5E3 FOREIGN KEY (CustomerID) REFERENCES Customer(Custid));
CREATE TABLE LoanAccount (Ln_accountid CHAR(7) PRIMARY KEY, Customer CHAR(8) NOT NULL, loan_amount DECIMAL(12,2) NULL, Start_date DATE NOT NULL, Tenure INT NOT NULL, Ln_roi DECIMAL(4,2) NOT NULL, Emi DECIMAL(12,2) NULL, CONSTRAINT FK_LoanAccount_Account FOREIGN KEY (Ln_accountid) REFERENCES Account(AccountID), CONSTRAINT FK_LoanAccount_Customer FOREIGN KEY (Customer) REFERENCES Customer(Custid));
CREATE TABLE SavingsTransaction (Transactionid INT IDENTITY(1,1) PRIMARY KEY, SBAccountID CHAR(7) NOT NULL, Transationdate DATETIME NULL, Transactiontype VARCHAR(10) NULL, Amount DECIMAL(18,2) NULL, CONSTRAINT FK_SavingsTransaction_SavingsAccount FOREIGN KEY (SBAccountID) REFERENCES SavingsAccount(SBAccountID));
CREATE TABLE FDTransaction (TransactionID INT PRIMARY KEY, FDAccountID CHAR(7) NULL, TransactionType VARCHAR(15) NULL, Amount SMALLMONEY NOT NULL, TransactionDate DATETIME NULL, CONSTRAINT FK__FDTransac__FDAcc__540C7B00 FOREIGN KEY (FDAccountID) REFERENCES FixedDepositAccount(FDAccountID));
CREATE TABLE LoanTransaction (Transactionno INT IDENTITY(1,1) PRIMARY KEY, Ln_accountid CHAR(7) NOT NULL, Emidate DATETIME NULL, Amount DECIMAL(12,2) NULL, Outstanding DECIMAL(12,2) NULL, PaymentType VARCHAR(20) NULL, PaidBy CHAR(8) NULL, CONSTRAINT FK_LoanTransaction_LoanAccount FOREIGN KEY (Ln_accountid) REFERENCES LoanAccount(Ln_accountid));
CREATE TABLE FundTransfer (TransferID INT IDENTITY(1,1) PRIMARY KEY, FromAccountID CHAR(7) NOT NULL, ToAccountID CHAR(7) NOT NULL, Amount DECIMAL(12,2) NOT NULL, TransferDate DATETIME NOT NULL, FromCustomerID CHAR(8) NOT NULL, ToCustomerID CHAR(8) NOT NULL, Status VARCHAR(20) NOT NULL, Remarks VARCHAR(200) NULL, CONSTRAINT FK_FundTransfer_FromAccount FOREIGN KEY (FromAccountID) REFERENCES SavingsAccount(SBAccountID), CONSTRAINT FK_FundTransfer_ToAccount FOREIGN KEY (ToAccountID) REFERENCES SavingsAccount(SBAccountID), CONSTRAINT FK_FundTransfer_FromCustomer FOREIGN KEY (FromCustomerID) REFERENCES Customer(Custid), CONSTRAINT FK_FundTransfer_ToCustomer FOREIGN KEY (ToCustomerID) REFERENCES Customer(Custid));
GO
```

### 3. Insert Basic Data

```sql
-- Departments
INSERT INTO Department VALUES ('DEPT01', 'Deposit Management'), ('DEPT02', 'Loan Management'), ('DEPT03', 'HR Department');

-- Manager
INSERT INTO Manager VALUES ('MGR001', 'Admin Manager', 'ADMIN12345');
INSERT INTO UserLogin VALUES ('admin', 'admin', 'hashed_password_here', 'MANAGER', 'MGR001');
GO
```

---

## ?? Table Structure Summary

| # | Table Name | Primary Key | Key Relationships | Purpose |
|---|------------|-------------|-------------------|---------|
| 1 | **Department** | Deptid | ? Employee | Store departments (DEPT01, DEPT02, DEPT03) |
| 2 | **Manager** | ManagerID | ? UserLogin | Store manager details |
| 3 | **Customer** | Custid | ? Account, Savings, FD, Loan, FundTransfer | Store customer information (MLA00001) |
| 4 | **Employee** | Empid | Department ? | Store employee details (2600001) |
| 5 | **UserLogin** | UserID | - | Store all user login credentials |
| 6 | **Account** | AccountID | Customer ?, ? Savings/FD/Loan | Master account table (SB/FD/LA + 00001) |
| 7 | **SavingsAccount** | SBAccountID | Account ?, Customer ? | Savings account details (SB00001) |
| 8 | **FixedDepositAccount** | FDAccountID | Account ?, Customer ? | FD account with maturity calculation |
| 9 | **LoanAccount** | Ln_accountid | Account ?, Customer ? | Loan account details (LA00001) |
| 10 | **SavingsTransaction** | Transactionid | SavingsAccount ? | All savings transactions |
| 11 | **FDTransaction** | TransactionID | FixedDepositAccount ? | FD transactions |
| 12 | **LoanTransaction** | Transactionno | LoanAccount ? | Loan EMI payments |
| 13 | **FundTransfer** | TransferID | 2x SavingsAccount ?, 2x Customer ? | Customer fund transfers |

---

## ?? Most Used Queries

### Get Customer with All Accounts

```sql
SELECT c.Custid, c.Custname, a.AccountID, a.AccountType, a.Status
FROM Customer c
LEFT JOIN Account a ON c.Custid = a.CustomerID
WHERE c.Custid = 'MLA00001';
```

### Get Savings Transactions

```sql
SELECT st.*, sa.Balance
FROM SavingsTransaction st
JOIN SavingsAccount sa ON st.SBAccountID = sa.SBAccountID
WHERE st.SBAccountID = 'SB00001'
ORDER BY st.Transationdate DESC;
```

### Get Statistics

```sql
-- Quick dashboard stats
SELECT 
    (SELECT COUNT(*) FROM Customer) AS TotalCustomers,
    (SELECT COUNT(*) FROM Employee) AS TotalEmployees,
    (SELECT COUNT(*) FROM Account WHERE Status = 'OPEN') AS ActiveAccounts,
    (SELECT SUM(Balance) FROM SavingsAccount) AS TotalSavings;
```

### Delete All Data (For Testing)

```sql
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
EXEC sp_MSforeachtable 'DELETE FROM ?';
EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL';
EXEC sp_MSforeachtable 'IF OBJECTPROPERTY(OBJECT_ID(''?''), ''TableHasIdentity'') = 1 DBCC CHECKIDENT(''?'', RESEED, 0)';
```

---

## ?? ID Formats

| Entity | Format | Example | Length |
|--------|--------|---------|--------|
| Customer | MLA + 5 digits | MLA00001 | 8 chars |
| Employee | 26 + 5 digits | 2600001 | 7 chars |
| Savings Account | SB + 5 digits | SB00001 | 7 chars |
| FD Account | FD + 5 digits | FD00001 | 7 chars |
| Loan Account | LA + 5 digits | LA00001 | 7 chars |

---

## ?? Check Constraints (Important!)

```sql
-- Add after table creation
ALTER TABLE Account ADD CONSTRAINT CK_Account_Status CHECK (Status IN ('OPEN', 'CLOSED'));
ALTER TABLE Account ADD CONSTRAINT CK_Account_Type CHECK (AccountType IN ('SAVING', 'FIXED-DEPOSIT', 'LOAN'));
ALTER TABLE SavingsTransaction ADD CONSTRAINT CK_SavingsTransaction_Type CHECK (Transactiontype IN ('DEPOSIT', 'WITHDRAW', 'TRANSFER_DEBIT', 'TRANSFER_CREDIT', 'INITIAL DEPOSIT'));
ALTER TABLE FundTransfer ADD CONSTRAINT CK_FundTransfer_Status CHECK (Status IN ('SUCCESS', 'FAILED', 'PENDING'));
ALTER TABLE LoanTransaction ADD CONSTRAINT CK_LoanTransaction_PaymentType CHECK (PaymentType IN ('EMI', 'PART_PAYMENT', 'FULL_CLOSURE'));
ALTER TABLE UserLogin ADD CONSTRAINT CK_UserLogin_Role CHECK (Role IN ('MANAGER', 'EMPLOYEE', 'CUSTOMER'));
```

---

## ?? Key Data Types

| Type | Used For | Max Length | Example |
|------|----------|------------|---------|
| CHAR(n) | Fixed-length IDs | Specified | 'SB00001' |
| VARCHAR(n) | Variable text | Specified | 'John Smith' |
| DECIMAL(12,2) | Money amounts | 12 digits, 2 decimal | 10000.50 |
| SMALLMONEY | Small amounts | 4 decimal places | 1000.0000 |
| DATE | Dates only | - | 2025-01-15 |
| DATETIME | Date + Time | - | 2025-01-15 10:30:00 |
| INT | Integers | - | 1, 2, 3... |
| IDENTITY | Auto-increment | - | 1, 2, 3... |

---

## ?? Testing Commands

### View All Tables
```sql
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
```

### View All Foreign Keys
```sql
SELECT fk.name, tp.name AS Parent_Table, tr.name AS Referenced_Table
FROM sys.foreign_keys AS fk
JOIN sys.tables AS tp ON fk.parent_object_id = tp.object_id
JOIN sys.tables AS tr ON fk.referenced_object_id = tr.object_id;
```

### Check Column Sizes
```sql
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SavingsTransaction' AND COLUMN_NAME = 'Transactiontype';
```

---

## ?? Computed Column

**FixedDepositAccount.MaturityAmount** is auto-calculated:

```sql
MaturityAmount = Amount × (1 + FD_ROI/100)^(Tenure in years)
```

**Example:**
- Amount: ?100,000
- FD_ROI: 7%
- Tenure: 24 months (2 years)
- **Result:** ?114,490

---

## ?? Documentation Reference

**Full documentation with 100+ commands:**  
`DOCS/Complete_SSMS_Commands_From_Model1.md`

---

**Last Updated:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

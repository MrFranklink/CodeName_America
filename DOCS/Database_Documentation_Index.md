# ?? Banking_Details Database - Complete Documentation Index

## ?? All SSMS/SQL Commands from Model1.edmx

This index provides quick access to all SQL documentation for the Banking_Details database.

---

## ?? Main Documentation Files

| Document | Description | Commands | Size |
|----------|-------------|----------|------|
| **[Complete_SSMS_Commands_From_Model1.md](./Complete_SSMS_Commands_From_Model1.md)** | Full comprehensive documentation with all SQL commands | 100+ | Complete |
| **[SSMS_Commands_Quick_Reference.md](./SSMS_Commands_Quick_Reference.md)** | Quick reference with most-used commands | 20+ | Summary |
| **This File** | Navigation index | - | Index |

---

## ??? What's Included

### 1. Complete Documentation (`Complete_SSMS_Commands_From_Model1.md`)

**Sections:**
1. ? Create Database
2. ? Create Tables (13 tables)
3. ? Foreign Key Relationships (18 FKs)
4. ? Computed Columns
5. ? Indexes & Constraints
6. ? Sample Data Insert
7. ? Useful Queries (20+ queries)
8. ? Maintenance Commands
9. ? Column Data Types Summary
10. ? ID Formats & Auto-Generation
11. ? Complete Table Creation Script (Copy-Paste Ready)

**Total Commands:** 100+

---

### 2. Quick Reference (`SSMS_Commands_Quick_Reference.md`)

**Sections:**
1. ? Quick Start (Create Database & Tables)
2. ? Table Structure Summary
3. ? Most Used Queries
4. ? ID Formats
5. ? Check Constraints
6. ? Key Data Types
7. ? Testing Commands
8. ? Computed Column Example

**Total Commands:** 20+ essential commands

---

## ??? Database Structure Overview

### ?? Entity Relationship Summary

```
Banking_Details
?
??? Department (3 depts: DEPT01, DEPT02, DEPT03)
?   ??? Employee
?
??? Manager
?
??? Customer
?   ??? Account (Master)
?   ?   ??? SavingsAccount (SB00001)
?   ?   ?   ??? SavingsTransaction
?   ?   ?   ??? FundTransfer (From/To)
?   ?   ?
?   ?   ??? FixedDepositAccount (FD00001)
?   ?   ?   ??? FDTransaction
?   ?   ?
?   ?   ??? LoanAccount (LA00001)
?   ?       ??? LoanTransaction
?   ?
?   ??? FundTransfer (From/To)
?
??? UserLogin (All users: Manager, Employee, Customer)
```

---

## ?? Tables List (13 Total)

| # | Table | Purpose | Primary Key | Relationships |
|---|-------|---------|-------------|---------------|
| 1 | Department | Departments | Deptid (CHAR 6) | ? Employee |
| 2 | Manager | Managers | ManagerID (VARCHAR 8) | ? UserLogin |
| 3 | Customer | Customers | Custid (CHAR 8) | ? Account, Savings, FD, Loan, FundTransfer |
| 4 | Employee | Employees | Empid (VARCHAR 20) | Department ? |
| 5 | UserLogin | All logins | UserID (VARCHAR 20) | - |
| 6 | Account | Master accounts | AccountID (CHAR 7) | Customer ?, ? Savings/FD/Loan |
| 7 | SavingsAccount | Savings details | SBAccountID (CHAR 7) | Account ?, Customer ? |
| 8 | FixedDepositAccount | FD details | FDAccountID (CHAR 7) | Account ?, Customer ? |
| 9 | LoanAccount | Loan details | Ln_accountid (CHAR 7) | Account ?, Customer ? |
| 10 | SavingsTransaction | Savings txns | Transactionid (INT) | SavingsAccount ? |
| 11 | FDTransaction | FD txns | TransactionID (INT) | FixedDepositAccount ? |
| 12 | LoanTransaction | Loan txns | Transactionno (INT) | LoanAccount ? |
| 13 | FundTransfer | Transfers | TransferID (INT) | 2x SavingsAccount ?, 2x Customer ? |

---

## ?? Quick Commands Reference

### Create Database
```sql
CREATE DATABASE Banking_Details;
GO
USE Banking_Details;
GO
```

### Get All Tables
```sql
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
```

### Get Statistics
```sql
SELECT 
    (SELECT COUNT(*) FROM Customer) AS TotalCustomers,
    (SELECT COUNT(*) FROM Employee) AS TotalEmployees,
    (SELECT COUNT(*) FROM Account WHERE Status = 'OPEN') AS ActiveAccounts;
```

### Delete All Data (For Testing)
```sql
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
EXEC sp_MSforeachtable 'DELETE FROM ?';
EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL';
```

---

## ?? ID Formats

| Entity | Format | Example | Length |
|--------|--------|---------|--------|
| Customer | MLA + 5 digits | MLA00001 | 8 chars |
| Employee | 26 + 5 digits | 2600001 | 7 chars |
| Manager | MGR + 3 digits | MGR001 | 6 chars |
| Savings Account | SB + 5 digits | SB00001 | 7 chars |
| FD Account | FD + 5 digits | FD00001 | 7 chars |
| Loan Account | LA + 5 digits | LA00001 | 7 chars |

---

## ?? Key Relationships (18 Foreign Keys)

1. `Employee.DeptId` ? `Department.Deptid`
2. `Account.CustomerID` ? `Customer.Custid`
3. `SavingsAccount.SBAccountID` ? `Account.AccountID`
4. `SavingsAccount.Customerid` ? `Customer.Custid`
5. `FixedDepositAccount.FDAccountID` ? `Account.AccountID`
6. `FixedDepositAccount.CustomerID` ? `Customer.Custid`
7. `LoanAccount.Ln_accountid` ? `Account.AccountID`
8. `LoanAccount.Customer` ? `Customer.Custid`
9. `SavingsTransaction.SBAccountID` ? `SavingsAccount.SBAccountID`
10. `FDTransaction.FDAccountID` ? `FixedDepositAccount.FDAccountID`
11. `LoanTransaction.Ln_accountid` ? `LoanAccount.Ln_accountid`
12. `FundTransfer.FromAccountID` ? `SavingsAccount.SBAccountID`
13. `FundTransfer.ToAccountID` ? `SavingsAccount.SBAccountID`
14. `FundTransfer.FromCustomerID` ? `Customer.Custid`
15. `FundTransfer.ToCustomerID` ? `Customer.Custid`

---

## ?? Special Features

### Computed Column
**FixedDepositAccount.MaturityAmount** is auto-calculated:
```sql
MaturityAmount = Amount × (1 + FD_ROI/100)^(Tenure in years)
```

### IDENTITY Columns (Auto-increment)
- `SavingsTransaction.Transactionid`
- `LoanTransaction.Transactionno`
- `FundTransfer.TransferID`

---

## ?? Transaction Types

### SavingsTransaction.Transactiontype
- `DEPOSIT`
- `WITHDRAW`
- `TRANSFER_DEBIT`
- `TRANSFER_CREDIT`
- `INITIAL DEPOSIT`

### FundTransfer.Status
- `SUCCESS`
- `FAILED`
- `PENDING`

### LoanTransaction.PaymentType
- `EMI` - Regular monthly payment
- `PART_PAYMENT` - Extra payment
- `FULL_CLOSURE` - Complete closure

### Account.Status
- `OPEN`
- `CLOSED`

### Account.AccountType
- `SAVING`
- `FIXED-DEPOSIT`
- `LOAN`

### UserLogin.Role
- `MANAGER`
- `EMPLOYEE`
- `CUSTOMER`

---

## ?? Common Queries

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

### Get Loan Outstanding
```sql
SELECT la.*, ISNULL(lt.Outstanding, la.loan_amount) AS CurrentOutstanding
FROM LoanAccount la
LEFT JOIN (
    SELECT Ln_accountid, Outstanding,
           ROW_NUMBER() OVER (PARTITION BY Ln_accountid ORDER BY Emidate DESC) AS rn
    FROM LoanTransaction
) lt ON la.Ln_accountid = lt.Ln_accountid AND lt.rn = 1
WHERE la.Ln_accountid = 'LA00001';
```

---

## ??? Maintenance Commands

### Backup Database
```sql
BACKUP DATABASE Banking_Details 
TO DISK = 'C:\Backup\Banking_Details.bak'
WITH FORMAT;
```

### Restore Database
```sql
RESTORE DATABASE Banking_Details 
FROM DISK = 'C:\Backup\Banking_Details.bak'
WITH REPLACE;
```

### Check Database Size
```sql
EXEC sp_spaceused;
```

### View All Constraints
```sql
SELECT 
    OBJECT_NAME(parent_object_id) AS TableName,
    name AS ConstraintName,
    type_desc AS ConstraintType
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT'
ORDER BY TableName, type_desc;
```

---

## ?? Documentation Navigation

### Start Here:
1. **New to the database?** ? Read `SSMS_Commands_Quick_Reference.md`
2. **Need all details?** ? Read `Complete_SSMS_Commands_From_Model1.md`
3. **Need specific query?** ? Search this index file

### External References:
- **Entity Framework Model:** `DB/Model1.edmx`
- **C# Context Class:** `DB/Model1.Context.cs`
- **Repositories:** `DB/*Repository.cs`
- **Services:** `BankApp.Services/*.cs`

---

## ? Verification Checklist

Before deploying, verify:

- [ ] All 13 tables created
- [ ] All 18 foreign keys working
- [ ] Check constraints added
- [ ] Unique constraints added
- [ ] MaturityAmount computed column working
- [ ] IDENTITY columns working
- [ ] Sample data inserted successfully
- [ ] All queries run without errors

---

## ?? Learning Resources

### Understanding the Structure:
1. Start with `Department`, `Manager`, `Customer` tables
2. Move to `Account` (master table)
3. Understand child tables: `SavingsAccount`, `FixedDepositAccount`, `LoanAccount`
4. Learn transaction tables: `SavingsTransaction`, `FDTransaction`, `LoanTransaction`
5. Explore `FundTransfer` table

### Key Concepts:
- **Master-Child Relationship:** Account ? SavingsAccount/FDAccount/LoanAccount
- **One-to-Many:** Customer ? Multiple Accounts
- **Many-to-Many:** FundTransfer connects two SavingsAccounts
- **Computed Columns:** MaturityAmount auto-calculates
- **Cascading:** Deleting Account doesn't auto-delete child (by design)

---

## ?? Support

**For SQL Issues:**
- Check `DOCS/Complete_SSMS_Commands_From_Model1.md`
- Check `DOCS/SSMS_Commands_Quick_Reference.md`
- Review column sizes, data types, constraints

**For Application Issues:**
- Check `BankApp.Services/*.cs` (Business Logic)
- Check `DB/*Repository.cs` (Data Access)
- Check `Bank_App/Controllers/*.cs` (Web Layer)

---

## ?? Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2025-01-XX | 1.0 | Initial documentation created from Model1.edmx |
| - | - | All 13 tables documented |
| - | - | All 18 foreign keys documented |
| - | - | 100+ SQL commands provided |

---

## ?? Summary

? **13 Tables** fully documented  
? **18 Foreign Keys** explained  
? **100+ SQL Commands** ready to use  
? **Quick Reference** for common tasks  
? **Complete Documentation** for advanced use  

---

**Documentation Index Created:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Source:** Model1.edmx (Entity Framework 6)  
**Database:** Banking_Details  
**Target:** SQL Server 2012+  

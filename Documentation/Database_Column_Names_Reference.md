# Database Column Names Reference

## ?? Quick Reference: Actual Column Names

This document provides the **actual column names** as they exist in the database and Entity Framework models.

---

## ?? Common Mistakes

### ? **WRONG** ? ? **CORRECT**

| Table | Wrong Name | Correct Name |
|-------|------------|--------------|
| Customer | `CustomerName` | `Custname` |
| Customer | `DateOfBirth` | `DOB` |
| Customer | `ContactNo` | `PhoneNumber` |
| Customer | `PAN` | `Pan` |
| Employee | `EmployeeId` | `Empid` |
| Employee | `DepartmentId` | `DeptId` |
| Employee | `PAN` | `PAN` ? |
| Manager | `PAN` | `PAN` ? |

---

## ?? Complete Table Schemas

### **Customer Table**

```sql
CREATE TABLE Customer (
    Custid VARCHAR(50) PRIMARY KEY,           -- Customer ID
    Custname VARCHAR(100),                     -- Customer Name ?? Not "CustomerName"
    DOB DATETIME,                              -- Date of Birth ?? Not "DateOfBirth"
    Pan VARCHAR(10),                           -- PAN Number (capitalization: Pan)
    Address VARCHAR(200),                      -- Address
    PhoneNumber VARCHAR(15)                    -- Phone ?? Not "ContactNo"
);
```

**C# Entity Properties:**
```csharp
public class Customer
{
    public string Custid { get; set; }         // Primary Key
    public string Custname { get; set; }       // ?? Not CustomerName
    public DateTime? DOB { get; set; }         // ?? Not DateOfBirth
    public string Pan { get; set; }            // PAN
    public string Address { get; set; }        // Address
    public string PhoneNumber { get; set; }    // ?? Not ContactNo
}
```

---

### **Employee Table**

```sql
CREATE TABLE Employee (
    Empid VARCHAR(50) PRIMARY KEY,             -- Employee ID ?? Not "EmployeeId"
    EmployeeName VARCHAR(100),                 -- Employee Name
    DeptId VARCHAR(10),                        -- Department ID ?? Not "DepartmentId"
    PAN VARCHAR(10),                           -- PAN Number (all caps)
    Salary DECIMAL(18,2)                       -- Monthly Salary
);
```

**C# Entity Properties:**
```csharp
public class Employee
{
    public string Empid { get; set; }          // ?? Not EmployeeId
    public string EmployeeName { get; set; }   // Employee Name
    public string DeptId { get; set; }         // ?? Not DepartmentId
    public string PAN { get; set; }            // PAN (all caps)
    public decimal? Salary { get; set; }       // Salary
}
```

---

### **Manager Table**

```sql
CREATE TABLE Manager (
    ManagerID VARCHAR(50) PRIMARY KEY,         -- Manager ID
    ManagerName VARCHAR(100),                  -- Manager Name
    PAN VARCHAR(10)                            -- PAN Number (all caps)
);
```

**C# Entity Properties:**
```csharp
public class Manager
{
    public string ManagerID { get; set; }      // Primary Key
    public string ManagerName { get; set; }    // Manager Name
    public string PAN { get; set; }            // PAN (all caps)
}
```

---

### **UserLogin Table**

```sql
CREATE TABLE UserLogin (
    UserID VARCHAR(50) PRIMARY KEY,            -- User ID
    UserName VARCHAR(50) UNIQUE,               -- Username
    PasswordHash VARCHAR(255),                 -- Hashed Password
    Role VARCHAR(20),                          -- CUSTOMER, EMPLOYEE, MANAGER
    ReferenceID VARCHAR(50)                    -- Points to Custid, Empid, or ManagerID
);
```

**C# Entity Properties:**
```csharp
public class UserLogin
{
    public string UserID { get; set; }         // Primary Key
    public string UserName { get; set; }       // Username
    public string PasswordHash { get; set; }   // Password Hash
    public string Role { get; set; }           // Role
    public string ReferenceID { get; set; }    // Foreign Reference
}
```

---

### **Account Table**

```sql
CREATE TABLE Account (
    AccountID VARCHAR(50) PRIMARY KEY,         -- Account ID
    CustomerID VARCHAR(50),                    -- Customer ID (FK)
    AccountType VARCHAR(20),                   -- SAVING, FIXED-DEPOSIT, LOAN
    Status VARCHAR(20),                        -- OPEN, CLOSED, PENDING
    OpenedDate DATETIME,                       -- Date Opened
    ClosedDate DATETIME,                       -- Date Closed (nullable)
    OpenedBy VARCHAR(50)                       -- Employee ID who opened
);
```

**C# Entity Properties:**
```csharp
public class Account
{
    public string AccountID { get; set; }      // Primary Key
    public string CustomerID { get; set; }     // Foreign Key
    public string AccountType { get; set; }    // Type
    public string Status { get; set; }         // Status
    public DateTime? OpenedDate { get; set; }  // Opened Date
    public DateTime? ClosedDate { get; set; }  // Closed Date
    public string OpenedBy { get; set; }       // Employee ID
}
```

---

### **SavingsAccount Table**

```sql
CREATE TABLE SavingsAccount (
    AccountID VARCHAR(50) PRIMARY KEY,         -- Account ID (FK to Account)
    Balance DECIMAL(18,2)                      -- Current Balance
);
```

**C# Entity Properties:**
```csharp
public class SavingsAccount
{
    public string AccountID { get; set; }      // Primary/Foreign Key
    public decimal? Balance { get; set; }      // Balance
    
    // Navigation Property
    public virtual Account Account { get; set; }
}
```

---

### **FixedDepositAccount Table**

```sql
CREATE TABLE FixedDepositAccount (
    AccountID VARCHAR(50) PRIMARY KEY,         -- Account ID (FK)
    Amount DECIMAL(18,2),                      -- FD Amount
    InterestRate DECIMAL(5,2),                 -- Interest Rate (%)
    Tenure INT,                                -- Tenure (months)
    MaturityDate DATETIME,                     -- Maturity Date
    MaturityAmount DECIMAL(18,2)               -- Maturity Amount
);
```

**C# Entity Properties:**
```csharp
public class FixedDepositAccount
{
    public string AccountID { get; set; }      // Primary/Foreign Key
    public decimal? Amount { get; set; }       // FD Amount
    public decimal? InterestRate { get; set; } // Interest Rate
    public int? Tenure { get; set; }           // Tenure (months)
    public DateTime? MaturityDate { get; set; } // Maturity Date
    public decimal? MaturityAmount { get; set; } // Maturity Amount
    
    // Navigation Properties
    public virtual Account Account { get; set; }
    public virtual Customer Customer { get; set; }
}
```

---

### **LoanAccount Table**

```sql
CREATE TABLE LoanAccount (
    AccountID VARCHAR(50) PRIMARY KEY,         -- Account ID (FK)
    LoanAmount DECIMAL(18,2),                  -- Loan Amount
    InterestRate DECIMAL(5,2),                 -- Interest Rate (%)
    Tenure INT,                                -- Tenure (months)
    EMI DECIMAL(18,2),                         -- EMI Amount
    AmountPaid DECIMAL(18,2),                  -- Amount Paid
    RemainingAmount DECIMAL(18,2),             -- Remaining Amount
    StartDate DATETIME,                        -- EMI Start Date
    EndDate DATETIME                           -- Loan End Date
);
```

**C# Entity Properties:**
```csharp
public class LoanAccount
{
    public string AccountID { get; set; }      // Primary/Foreign Key
    public decimal? LoanAmount { get; set; }   // Loan Amount
    public decimal? InterestRate { get; set; } // Interest Rate
    public int? Tenure { get; set; }           // Tenure
    public decimal? EMI { get; set; }          // EMI
    public decimal? AmountPaid { get; set; }   // Amount Paid
    public decimal? RemainingAmount { get; set; } // Remaining
    public DateTime? StartDate { get; set; }   // Start Date
    public DateTime? EndDate { get; set; }     // End Date
    
    // Navigation Properties
    public virtual Account Account { get; set; }
    public virtual Customer Customer { get; set; }
}
```

---

### **SavingsTransaction Table**

```sql
CREATE TABLE SavingsTransaction (
    TransactionID INT IDENTITY PRIMARY KEY,    -- Auto-increment
    AccountID VARCHAR(50),                     -- Account ID (FK)
    TransactionType VARCHAR(20),               -- DEPOSIT, WITHDRAW
    Amount DECIMAL(18,2),                      -- Transaction Amount
    TransactionDate DATETIME,                  -- Date of Transaction
    PerformedBy VARCHAR(50)                    -- Employee/Customer who performed
);
```

**C# Entity Properties:**
```csharp
public class SavingsTransaction
{
    public int TransactionID { get; set; }     // Auto-increment PK
    public string AccountID { get; set; }      // Foreign Key
    public string TransactionType { get; set; } // DEPOSIT/WITHDRAW
    public decimal? Amount { get; set; }       // Amount
    public DateTime? TransactionDate { get; set; } // Date
    public string PerformedBy { get; set; }    // Who performed
    
    // Navigation Property
    public virtual SavingsAccount SavingsAccount { get; set; }
}
```

---

### **Department Table**

```sql
CREATE TABLE Department (
    DeptId VARCHAR(10) PRIMARY KEY,            -- Department ID
    DepartmentName VARCHAR(100)                -- Department Name
);
```

**Sample Data:**
```
DEPT01 - Deposit Management
DEPT02 - Loan Management
DEPT03 - Human Resources
```

**C# Entity Properties:**
```csharp
public class Department
{
    public string DeptId { get; set; }         // Primary Key
    public string DepartmentName { get; set; } // Department Name
    
    // Navigation Property
    public virtual ICollection<Employee> Employees { get; set; }
}
```

---

## ?? How to Find Column Names

### Method 1: Check Entity Framework Model

1. Open `DB/Model1.edmx`
2. Find the entity (e.g., `Customer`)
3. Look at the properties in the **Properties Window**

### Method 2: Check Entity Class Files

```
DB/Customer.cs       ? Customer table columns
DB/Employee.cs       ? Employee table columns
DB/Manager.cs        ? Manager table columns
DB/Account.cs        ? Account table columns
DB/SavingsAccount.cs ? SavingsAccount table columns
```

### Method 3: Query Database Directly

```sql
-- Get all column names for Customer table
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer'
ORDER BY ORDINAL_POSITION;
```

### Method 4: Use SQL Server Management Studio

1. Open **SSMS**
2. Expand **Banking_Details** database
3. Expand **Tables**
4. Right-click **dbo.Customer** ? **Design**
5. View column names in designer

---

## ?? Naming Conventions Used

### Pattern Analysis

| Entity | ID Column | Name Column | Notes |
|--------|-----------|-------------|-------|
| Customer | `Custid` | `Custname` | Abbreviated "Cust" |
| Employee | `Empid` | `EmployeeName` | Full "Employee" |
| Manager | `ManagerID` | `ManagerName` | Full "Manager" |

**Observation:**
- Customer uses **abbreviations** (Custid, Custname, DOB)
- Employee and Manager use **full names** (EmployeeName, ManagerName)
- This inconsistency is why mistakes happen

---

## ? Validation Queries

### Check Column Names for All Tables

```sql
-- Customer columns
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Customer' ORDER BY ORDINAL_POSITION;

-- Employee columns
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Employee' ORDER BY ORDINAL_POSITION;

-- Manager columns
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Manager' ORDER BY ORDINAL_POSITION;

-- UserLogin columns
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'UserLogin' ORDER BY ORDINAL_POSITION;

-- Account columns
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Account' ORDER BY ORDINAL_POSITION;
```

---

## ?? Quick Copy-Paste Reference

### Customer INSERT Statement
```sql
INSERT INTO Customer (Custid, Custname, DOB, Pan, Address, PhoneNumber)
VALUES ('MLA00001', 'John Doe', '1990-01-01', 'ABCDE1234F', '123 Main St', '9876543210');
```

### Employee INSERT Statement
```sql
INSERT INTO Employee (Empid, EmployeeName, DeptId, PAN, Salary)
VALUES ('2600001', 'Jane Smith', 'DEPT01', 'FGHIJ5678K', 50000.00);
```

### Manager INSERT Statement
```sql
INSERT INTO Manager (ManagerID, ManagerName, PAN)
VALUES ('MGR001', 'Admin Manager', 'KLMNO9012P');
```

### UserLogin INSERT Statement
```sql
INSERT INTO UserLogin (UserID, UserName, PasswordHash, Role, ReferenceID)
VALUES ('USR00001', 'johndoe', 'HashedPassword123', 'CUSTOMER', 'MLA00001');
```

---

## ?? Related Documentation

- [Entity Framework Model: DB/Model1.edmx](../DB/Model1.edmx)
- [Database Schema: SQL_Scripts/Create_Application_Tables.sql](../SQL_Scripts/Create_Application_Tables.sql)
- [UserLogin Cascade Delete: Documentation/UserLogin_Cascade_Delete_Complete_Solution.md](UserLogin_Cascade_Delete_Complete_Solution.md)

---

**Last Updated:** 2024  
**Purpose:** Reference guide to prevent column name errors  
**Status:** ? Complete and Verified

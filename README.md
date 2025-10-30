# :) Gen Bank - Banking Management System

[![.NET Framework](https://img.shields.io/badge/.NET%20Framework-4.8-blue.svg)](https://dotnet.microsoft.com/download/dotnet-framework/net48)
[![ASP.NET MVC](https://img.shields.io/badge/ASP.NET-MVC%205-green.svg)](https://www.asp.net/mvc)
[![Entity Framework](https://img.shields.io/badge/Entity%20Framework-6-orange.svg)](https://docs.microsoft.com/en-us/ef/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-red.svg)](https://www.microsoft.com/sql-server)
[![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple.svg)](https://getbootstrap.com/)

A comprehensive **Banking Management System** built with **ASP.NET MVC** that provides role-based access for **Managers**, **Employees**, and **Customers** to manage banking operations including customer registration, account management, transactions, loans, and fixed deposits.

---

## ?? Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Database Setup](#-database-setup)
- [User Roles](#-user-roles)
- [Screenshots](#-screenshots)
- [Project Structure](#-project-structure)
- [Key Features](#-key-features)
- [Security](#-security)
- [Contributing](#-contributing)
- [License](#-license)

---

## ? Features

### ?? Role-Based Access Control
- **Manager**: Full administrative access
- **Employee**: Department-specific operations
- **Customer**: Self-service banking

### ?? Manager Dashboard
- ? Register customers and employees
- ? Open savings, fixed deposit, and loan accounts
- ? Process deposits and withdrawals
- ? Approve/reject pending applications
- ? Edit customer and employee profiles
- ? Delete customers and employees (with validation)
- ? View transaction history
- ? Account management (open, close, foreclose)

### ????? Employee Dashboard
- ? Department-specific access (DEPT01, DEPT02, DEPT03)
- ? Register customers
- ? Open accounts based on department
- ? Process deposits/withdrawals (DEPT01 only)
- ? Approve/reject applications (department-specific)
- ? Edit customer profiles
- ? View accounts and customers

### ?? Customer Dashboard
- ? View account balances and details
- ? Deposit and withdraw from savings account
- ? Apply for fixed deposits and loans
- ? Transfer funds between accounts
- ? Pay loan EMIs
- ? View transaction history
- ? Export transactions (Excel/PDF)
- ? Change password

### ?? Account Management
- **Savings Account**: Minimum balance ?1,000
- **Fixed Deposit**: Interest rates 6-8% (senior citizen bonus)
- **Loan Account**: Salary-based eligibility, EMI calculator

### ?? Transaction Features
- Real-time balance updates
- Transaction history with filters
- Export to Excel/PDF
- Fund transfer between accounts
- Loan EMI payment tracking

---

## ??? Tech Stack

### Backend
- **Framework**: ASP.NET MVC 5 (.NET Framework 4.8)
- **ORM**: Entity Framework 6 (Database-First)
- **Database**: Microsoft SQL Server 2019+
- **Authentication**: Session-based with role management

### Frontend
- **UI Framework**: Bootstrap 5.3
- **Icons**: Bootstrap Icons
- **JavaScript**: Vanilla JS (ES6+)
- **CSS**: Custom styling with Bootstrap utilities

### Architecture
- **Pattern**: MVC (Model-View-Controller)
- **Service Layer**: Business logic separation
- **Repository Pattern**: Data access abstraction
- **DTO Pattern**: Data transfer objects

---

## ??? Architecture

```
???????????????????????????????????????????????????????
?                   Presentation Layer                 ?
?              (ASP.NET MVC Controllers)               ?
?  ????????????????  ????????????????  ????????????? ?
?  ? Auth         ?  ? Dashboard    ?  ? Views     ? ?
?  ? Controller   ?  ? Controller   ?  ? (Razor)   ? ?
?  ????????????????  ????????????????  ????????????? ?
???????????????????????????????????????????????????????
                        ?
???????????????????????????????????????????????????????
?                   Service Layer                      ?
?              (BankApp.Services)                      ?
?  ????????????????  ????????????????  ????????????? ?
?  ? Customer     ?  ? Account      ?  ? Loan      ? ?
?  ? Service      ?  ? Service      ?  ? Service   ? ?
?  ????????????????  ????????????????  ????????????? ?
???????????????????????????????????????????????????????
                        ?
???????????????????????????????????????????????????????
?                   Data Access Layer                  ?
?              (DB - Entity Framework)                 ?
?  ????????????????  ????????????????  ????????????? ?
?  ? Customer     ?  ? Account      ?  ? Loan      ? ?
?  ? Repository   ?  ? Repository   ?  ? Repository? ?
?  ????????????????  ????????????????  ????????????? ?
???????????????????????????????????????????????????????
                        ?
???????????????????????????????????????????????????????
?                   Database Layer                     ?
?                  (SQL Server)                        ?
?  ????????????????  ????????????????  ????????????? ?
?  ? Customer     ?  ? Account      ?  ? Loan      ? ?
?  ? Table        ?  ? Table        ?  ? Table     ? ?
?  ????????????????  ????????????????  ????????????? ?
???????????????????????????????????????????????????????
```

---

## ?? Getting Started

### Prerequisites
- **Visual Studio 2019/2022** (Community Edition or higher)
- **.NET Framework 4.8 SDK**
- **SQL Server 2019+** (Express Edition or higher)
- **SQL Server Management Studio (SSMS)** (optional, for database management)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/MrFranklink/CodeName_America.git
   cd CodeName_America
   ```

2. **Open the solution**
   ```bash
   # Open in Visual Studio
   start Bank_App.sln
   ```

3. **Restore NuGet packages**
   - In Visual Studio: `Tools` ? `NuGet Package Manager` ? `Restore NuGet Packages`
   - Or right-click solution ? `Restore NuGet Packages`

4. **Update connection strings**
   - Open `Bank_App/Web.config`
   - Update the connection string:
   ```xml
   <connectionStrings>
     <add name="Banking_DetailsEntities" 
          connectionString="metadata=res://*/Model1.csdl|res://*/Model1.ssdl|res://*/Model1.msl;
          provider=System.Data.SqlClient;
          provider connection string='data source=YOUR_SERVER_NAME;
          initial catalog=Banking_Details;
          integrated security=True;
          MultipleActiveResultSets=True;
          App=EntityFramework'" 
          providerName="System.Data.EntityClient" />
   </connectionStrings>
   ```

5. **Run database migration**
   - Open SSMS and connect to your SQL Server
   - Execute the master migration script:
   ```bash
   # Located at: SQL_Scripts/MASTER_MIGRATION_SCRIPT.sql
   ```

6. **Build and run**
   - Press `F5` or click `Start` in Visual Studio
   - The application will open at `https://localhost:44300` (or configured port)

---

## ??? Database Setup

### Quick Setup (Recommended)

Run the master migration script to create the entire database:

```sql
-- File: SQL_Scripts/MASTER_MIGRATION_SCRIPT.sql
-- This script creates all tables, triggers, and sample data
```

### Manual Setup

1. **Create Database**
   ```sql
   CREATE DATABASE Banking_Details;
   ```

2. **Create Tables**
   - Run table creation scripts from `SQL_Scripts/`

3. **Create Triggers**
   ```sql
   -- Run: SQL_Scripts/Create_All_Cascade_Delete_Triggers.sql
   ```

4. **Insert Sample Data**
   ```sql
   -- Run: SQL_Scripts/Insert_Sample_Data.sql (if available)
   ```

### Database Schema

**Main Tables:**
- `Customer` - Customer information
- `Employee` - Employee details
- `Manager` - Manager details
- `Department` - Department information
- `Account` - Base account table
- `SavingsAccount` - Savings account details
- `FixedDepositAccount` - FD account details
- `LoanAccount` - Loan account details
- `SavingsTransaction` - Transaction history
- `FundTransfer` - Fund transfer records
- `LoanTransaction` - Loan payment history
- `FDTransaction` - FD transaction history
- `UserLogin` - User authentication

---

## ?? User Roles

### ?? Default Credentials

**Manager:**
```
Username: MGR00001
Password: manager123
```

**Employee (DEPT01 - Deposit Management):**
```
Username: EMP00001
Password: employee123
```

**Employee (DEPT02 - Loan Management):**
```
Username: EMP00002
Password: employee123
```

**Customer:**
```
Username: MLA00001
Password: customer123
```

### Role Permissions

| Feature | Manager | Employee (DEPT01) | Employee (DEPT02) | Employee (DEPT03) | Customer |
|---------|---------|-------------------|-------------------|-------------------|----------|
| Register Customer | ? | ? | ? | ? | ? |
| Register Employee | ? | ? | ? | ? | ? |
| Open Savings Account | ? | ? | ? | ? | ? |
| Open Fixed Deposit | ? | ? | ? | ? | ? |
| Open Loan Account | ? | ? | ? | ? | ? |
| Process Deposit/Withdrawal | ? | ? | ? | ? | ? |
| Approve FD Applications | ? | ? | ? | ? | ? |
| Approve Loan Applications | ? | ? | ? | ? | ? |
| Edit Customer | ? | ? | ? | ? | ? |
| Edit Employee | ? | ? | ? | ? | ? |
| Delete Customer | ? | ? | ? | ? | ? |
| Delete Employee | ? | ? | ? | ? | ? |
| View Customers | ? | ? | ? | ? | ? |
| View Accounts | ? | ? | ? | ? | Own only |
| Self Deposit/Withdraw | ? | ? | ? | ? | ? |
| Apply for FD/Loan | ? | ? | ? | ? | ? |
| Transfer Funds | ? | ? | ? | ? | ? |
| Pay Loan EMI | ? | ? | ? | ? | ? |
| Export Transactions | ? | ? | ? | ? | ? |

---

## ?? Screenshots

### Login Page
![Login Page](docs/screenshots/login.png)

### Manager Dashboard
![Manager Dashboard](docs/screenshots/manager-dashboard.png)

### Employee Dashboard
![Employee Dashboard](docs/screenshots/employee-dashboard.png)

### Customer Dashboard
![Customer Dashboard](docs/screenshots/customer-dashboard.png)

### Transaction History
![Transaction History](docs/screenshots/transaction-history.png)

---

## ?? Project Structure

```
CodeName_America/
??? Bank_App/                      # Main MVC Web Application
?   ??? Controllers/               # MVC Controllers
?   ?   ??? AuthController.cs      # Authentication & Login
?   ?   ??? DashboardController.cs # Main Dashboard Logic
?   ??? Views/                     # Razor Views
?   ?   ??? Auth/                  # Login Views
?   ?   ??? Dashboard/             # Dashboard Views
?   ?   ?   ??? ManagerDashboard.cshtml
?   ?   ?   ??? EmployeeDashboard.cshtml
?   ?   ?   ??? CustomerDashboard.cshtml
?   ?   ??? Shared/                # Shared Layouts
?   ??? Content/                   # CSS, Images
?   ??? Scripts/                   # JavaScript files
?   ??? Web.config                 # App Configuration
?
??? BankApp.Services/              # Business Logic Layer
?   ??? AuthService.cs             # Authentication Logic
?   ??? CustomerService.cs         # Customer Operations
?   ??? EmployeeService.cs         # Employee Operations
?   ??? SavingsAccountService.cs   # Savings Account Logic
?   ??? FixedDepositAccountService.cs # FD Logic
?   ??? LoanAccountService.cs      # Loan Logic
?   ??? SavingsTransactionService.cs # Transaction Logic
?   ??? FundTransferService.cs     # Fund Transfer Logic
?
??? DB/                            # Data Access Layer
?   ??? Model1.edmx                # Entity Framework Model
?   ??? CustomerRepository.cs      # Customer Data Access
?   ??? EmployeeRepository.cs      # Employee Data Access
?   ??? AccountRepository.cs       # Account Data Access
?   ??? ManagerRepository.cs       # Manager Data Access
?   ??? UserLoginRepository.cs     # User Auth Data Access
?
??? SQL_Scripts/                   # Database Scripts
?   ??? MASTER_MIGRATION_SCRIPT.sql # Complete DB Setup
?   ??? Create_All_Cascade_Delete_Triggers.sql
?   ??? SAFE_DELETE_ALL_DATA_WITH_ROLLBACK.sql
?   ??? Test_Cascade_Delete_Triggers.sql
?
??? Documentation/                 # Project Documentation
?   ??? Implementation_Checklist.md
?   ??? Database_Column_Names_Reference.md
?   ??? UserLogin_Cascade_Delete_Complete_Solution.md
?   ??? Loan_Progress_Bar_Complete_Solution.md
?   ??? Customer_Transaction_Export_Feature.md
?   ??? Manager_Delete_Customer_Employee_Feature.md
?
??? README.md                      # This file
```

---

## ?? Key Features

### 1. Account Management
- **Savings Account**: 
  - Minimum balance: ?1,000
  - One account per customer
  - Instant deposits/withdrawals
  
- **Fixed Deposit**:
  - Interest rates: 6-8% (tenure-based)
  - Senior citizen bonus: +0.5%
  - Maturity calculation
  - Premature closure with penalty
  
- **Loan Account**:
  - Salary-based eligibility (30-60x monthly salary)
  - Dynamic interest rates (9-10%)
  - EMI calculator
  - Loan repayment tracking
  - Progress bar visualization

### 2. Transaction Processing
- Real-time balance updates
- Transaction history with date filters
- Export to Excel/PDF formats
- Duplicate transaction prevention
- Audit trail logging

### 3. Fund Transfer
- Internal account transfers
- Balance validation
- Transaction remarks
- Instant credit/debit

### 4. Approval Workflow
- Department-based approval routing
- Pending application queue
- Approve/reject with reasons
- Email notifications (future)

### 5. Security Features
- Session-based authentication
- Role-based authorization
- Password encryption (hashed)
- SQL injection prevention
- XSS protection
- CSRF tokens

### 6. Data Validation
- Server-side validation
- Client-side validation (HTML5 + JavaScript)
- PAN card format validation
- Phone number validation (Indian format)
- Date of birth validation (18+ years)

---

## ?? Security

### Authentication
- Session-based authentication
- Password hashing (SHA-256)
- Login attempt tracking
- Session timeout (30 minutes)

### Authorization
- Role-based access control (RBAC)
- Department-based permissions
- Action-level authorization

### Data Protection
- SQL injection prevention (parameterized queries)
- XSS protection (HTML encoding)
- CSRF tokens on forms
- Input validation (server + client)

### Database Security
- Cascade delete triggers
- Foreign key constraints
- Transaction isolation
- Stored procedures for sensitive operations

---

## ?? Testing

### Manual Testing
1. **Login as Manager**
   - Test all manager operations
   - Verify access control

2. **Login as Employee (each department)**
   - Test department-specific features
   - Verify approval workflow

3. **Login as Customer**
   - Test self-service features
   - Verify transaction limits

### Test Scenarios
- ? Customer registration
- ? Account opening (all types)
- ? Deposit/withdrawal operations
- ? Fund transfers
- ? Loan EMI payments
- ? FD/Loan application approval
- ? Customer/employee deletion
- ? Password change
- ? Transaction export

### Database Testing
- Run: `SQL_Scripts/Test_Cascade_Delete_Triggers.sql`
- Verify data integrity
- Test rollback scenarios

---

## ?? Performance

### Optimization Techniques
- Entity Framework query optimization
- Database indexing on primary/foreign keys
- Lazy loading for related entities
- Caching for static data
- Minified CSS/JavaScript

### Scalability
- Stateless architecture (session storage)
- Database connection pooling
- Asynchronous operations (future)
- Load balancing ready

---

## ?? Known Issues

1. **Email Notifications**: Not implemented (planned)
2. **Password Recovery**: Manual reset required
3. **Multi-language Support**: English only
4. **Mobile Responsiveness**: Partial support

---

## ??? Roadmap

### Version 2.0 (Planned)
- [ ] Email notifications
- [ ] SMS alerts for transactions
- [ ] Password recovery via email
- [ ] Multi-factor authentication (MFA)
- [ ] Advanced reporting dashboard
- [ ] Mobile app (Xamarin/MAUI)
- [ ] API for third-party integration
- [ ] Biometric authentication
- [ ] Real-time chat support
- [ ] Multi-language support

### Version 2.1 (Future)
- [ ] Cheque management
- [ ] Credit card module
- [ ] Investment accounts
- [ ] Insurance module
- [ ] Bill payment integration
- [ ] Recurring deposits

---

## ?? Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Open a Pull Request**

### Coding Standards
- Follow C# coding conventions
- Use meaningful variable names
- Add XML documentation comments
- Write unit tests for new features
- Update documentation

---

## ?? License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## ????? Authors

- **Your Name** - *Initial work* - [MrFranklink](https://github.com/MrFranklink)

See also the list of [contributors](https://github.com/MrFranklink/CodeName_America/contributors) who participated in this project.

---

## ?? Acknowledgments

- **Bootstrap Team** - UI Framework
- **Microsoft** - .NET Framework & Entity Framework
- **Stack Overflow Community** - Problem solving
- **GitHub** - Code hosting

---

## ?? Contact

**Project Link**: [https://github.com/MrFranklink/CodeName_America](https://github.com/MrFranklink/CodeName_America)

**Issues**: [https://github.com/MrFranklink/CodeName_America/issues](https://github.com/MrFranklink/CodeName_America/issues)

---

## ?? Documentation

For detailed documentation, see the `/Documentation` folder:

- [Implementation Checklist](Documentation/Implementation_Checklist.md)
- [Database Column Names Reference](Documentation/Database_Column_Names_Reference.md)
- [UserLogin Cascade Delete Solution](Documentation/UserLogin_Cascade_Delete_Complete_Solution.md)
- [Loan Progress Bar Feature](Documentation/Loan_Progress_Bar_Complete_Solution.md)
- [Customer Transaction Export](Documentation/Customer_Transaction_Export_Feature.md)
- [Manager Delete Features](Documentation/Manager_Delete_Customer_Employee_Feature.md)

---

## ? Show your support

Give a ?? if this project helped you!

---

## ?? Project Stats

![GitHub stars](https://img.shields.io/github/stars/MrFranklink/CodeName_America?style=social)
![GitHub forks](https://img.shields.io/github/forks/MrFranklink/CodeName_America?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/MrFranklink/CodeName_America?style=social)
![GitHub last commit](https://img.shields.io/github/last-commit/MrFranklink/CodeName_America)
![GitHub issues](https://img.shields.io/github/issues/MrFranklink/CodeName_America)
![GitHub pull requests](https://img.shields.io/github/issues-pr/MrFranklink/CodeName_America)

---

<div align="center">
  <h3>Made with ?? by the Gen Bank Team</h3>
  <p>© 2024 Gen Bank. All rights reserved.</p>
</div>

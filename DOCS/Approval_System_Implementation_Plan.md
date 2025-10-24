# ?? Loan & Fixed Deposit Approval System - Implementation Plan

## ?? Overview

Implementing a **Manager Approval Workflow** for Loan and Fixed Deposit accounts where:
- Employees create applications ? Status = `PENDING`
- Manager reviews and approves/rejects ? Status = `OPEN` or `REJECTED`
- Only approved accounts become active

---

## ?? Current Flow vs New Flow

### ? Current Flow
```
Employee opens Loan/FD ? Account.Status = "OPEN" ? Immediately active
```

### ? New Flow
```
Employee opens Loan/FD ? Account.Status = "PENDING" 
                     ?
             Manager reviews application
                     ?
           [APPROVE] ?? [REJECT]
                ?            ?
       Status = "OPEN"  Status = "REJECTED"
                ?            ?
      Customer can use   Inactive, visible to customer
```

---

## ?? Account Status Values

| Status | Meaning | Can Transact? | Visible to Customer? |
|--------|---------|---------------|---------------------|
| **PENDING** | Awaiting manager approval | ? No | ? Yes (as "Pending Approval") |
| **OPEN** | Approved and active | ? Yes | ? Yes |
| **REJECTED** | Manager rejected | ? No | ? Yes (with rejection reason) |
| **CLOSED** | Account closed | ? No | ? Yes |

---

## ??? Implementation Phases

### Phase 1: Backend Services ?

**Files to Modify:**
1. `BankApp.Services/FixedDepositAccountService.cs`
2. `BankApp.Services/LoanAccountService.cs`
3. `BankApp.Services/AccountManagementService.cs` (NEW methods)

**Changes:**
- `OpenFixedDepositAccount()` ? Set Status = "PENDING" instead of "OPEN"
- `OpenLoanAccount()` ? Set Status = "PENDING" instead of "OPEN"
- Add `ApproveAccount(accountId, approvedBy)` method
- Add `RejectAccount(accountId, rejectedBy, reason)` method
- Add `GetPendingAccounts()` method

---

### Phase 2: Database Repository Updates ?

**Files to Modify:**
1. `DB/AccountRepository.cs`

**New Methods:**
```csharp
public bool ApproveAccount(string accountId, string approvedBy);
public bool RejectAccount(string accountId, string rejectedBy, string reason);
public List<Account> GetPendingAccounts();
public List<Account> GetPendingAccountsByType(string accountType);
```

---

### Phase 3: Manager Dashboard - Approval Interface ?

**File to Modify:**
1. `Bank_App/Views/Dashboard/ManagerDashboard.cshtml`

**New Tab:** "Pending Approvals"

**Features:**
- Shows list of PENDING Loan and FD accounts
- Display account details:
  - Account ID
  - Customer ID & Name
  - Account Type (Loan/FD)
  - Amount/Loan Amount
  - Requested Date
  - Interest Rate
  - Employee who created it
- **Approve** button (green)
- **Reject** button (red)
- Modal for rejection reason

---

### Phase 4: Controller Actions ?

**File to Modify:**
1. `Bank_App/Controllers/DashboardController.cs`

**New Actions:**
```csharp
[HttpPost]
public ActionResult ApproveAccount(string accountId);

[HttpPost]
public ActionResult RejectAccount(string accountId, string reason);

[HttpGet]
public ActionResult GetPendingApprovals();
```

**Modify:**
- `Index()` ? Load pending approvals count for manager badge

---

### Phase 5: Employee Dashboard Updates ?

**File to Modify:**
1. `Bank_App/Views/Dashboard/EmployeeDashboard.cshtml`

**Changes:**
- Update success message when opening Loan/FD:
  - Before: "Account opened successfully"
  - After: "Application submitted for manager approval. Account ID: {id}"
- Show pending applications in "View Accounts" tab with PENDING badge

---

### Phase 6: Customer Dashboard Updates ?

**File to Modify:**
1. `Bank_App/Views/Dashboard/CustomerDashboard.cshtml`

**Changes:**
- Show pending accounts with status badge
- Display different badges:
  - ?? Yellow badge for PENDING ? "Pending Approval"
  - ?? Green badge for OPEN ? "Active"
  - ?? Red badge for REJECTED ? "Rejected"
  - ? Gray badge for CLOSED ? "Closed"
- Only allow transactions on OPEN accounts
- Show rejection reason if account rejected

---

## ??? Data Structure

### Account Table (Existing - No Changes Needed)
```sql
CREATE TABLE Account (
    AccountID VARCHAR(10) PRIMARY KEY,
    AccountType VARCHAR(20) NOT NULL,
    CustomerID VARCHAR(10) NOT NULL,
    OpenedBy VARCHAR(10) NOT NULL,
    OpenedByRole VARCHAR(20) NOT NULL,
    OpenDate DATETIME DEFAULT GETDATE(),
    Status VARCHAR(10) DEFAULT 'PENDING',  -- Changed default from 'OPEN'
    ClosedDate DATETIME NULL
);
```

### Optional: Add Rejection Reason Column
```sql
ALTER TABLE Account
ADD RejectionReason NVARCHAR(500) NULL,
    ApprovedBy VARCHAR(10) NULL,
    ApprovalDate DATETIME NULL;
```

---

## ?? Detailed Implementation Steps

### Step 1: Update FD Service (PENDING Status)
```csharp
// BankApp.Services/FixedDepositAccountService.cs
public AccountOperationResult OpenFixedDepositAccount(...)
{
    // ... existing validation ...
    
    // ? CHANGE: Create account with PENDING status
    bool accountCreated = _accountRepo.CreateAccountWithStatus(
        fdAccountId, 
        "FIXED-DEPOSIT", 
        customerId, 
        openedBy, 
        openedByRole,
        "PENDING"  // ?? NEW: Start as PENDING
    );
    
    // ? CHANGE: Update success message
    return Success(
        $"Fixed Deposit application submitted for approval! Application ID: {fdAccountId}, Amount: Rs. {amount:N2}. Awaiting manager approval.",
        fdAccountId,
        amount,
        maturityAmount,
        null,
        interestRate
    );
}
```

### Step 2: Update Loan Service (PENDING Status)
```csharp
// BankApp.Services/LoanAccountService.cs
public AccountOperationResult OpenLoanAccount(...)
{
    // ... existing validation ...
    
    // ? CHANGE: Create account with PENDING status
    bool accountCreated = _accountRepo.CreateAccountWithStatus(
        lnAccountId, 
        "LOAN", 
        customerId, 
        openedBy, 
        openedByRole,
        "PENDING"  // ?? NEW: Start as PENDING
    );
    
    // ? CHANGE: Update success message
    return Success(
        $"Loan application submitted for approval! Application ID: {lnAccountId}, Amount: Rs. {loanAmount:N2}. Awaiting manager approval.",
        lnAccountId,
        loanAmount,
        null,
        emi,
        interestRate
    );
}
```

### Step 3: Add Approval Service
```csharp
// BankApp.Services/AccountManagementService.cs
public class AccountApprovalService
{
    private readonly AccountRepository _accountRepo;
    
    public AccountApprovalService()
    {
        _accountRepo = new AccountRepository();
    }
    
    /// <summary>
    /// Approve a pending account
    /// </summary>
    public AccountOperationResult ApproveAccount(string accountId, string approvedBy)
    {
        try
        {
            var account = _accountRepo.GetAccountById(accountId);
            
            if (account == null)
            {
                return Error("Account not found");
            }
            
            if (account.Status != "PENDING")
            {
                return Error($"Cannot approve account with status: {account.Status}");
            }
            
            bool approved = _accountRepo.ApproveAccount(accountId, approvedBy);
            
            if (approved)
            {
                return Success($"Account {accountId} approved successfully. Customer can now use this account.");
            }
            else
            {
                return Error("Failed to approve account");
            }
        }
        catch (Exception ex)
        {
            return Error($"Approval failed: {ex.Message}");
        }
    }
    
    /// <summary>
    /// Reject a pending account
    /// </summary>
    public AccountOperationResult RejectAccount(string accountId, string rejectedBy, string reason)
    {
        try
        {
            var account = _accountRepo.GetAccountById(accountId);
            
            if (account == null)
            {
                return Error("Account not found");
            }
            
            if (account.Status != "PENDING")
            {
                return Error($"Cannot reject account with status: {account.Status}");
            }
            
            if (string.IsNullOrWhiteSpace(reason))
            {
                return Error("Rejection reason is required");
            }
            
            bool rejected = _accountRepo.RejectAccount(accountId, rejectedBy, reason);
            
            if (rejected)
            {
                return Success($"Account {accountId} rejected. Reason: {reason}");
            }
            else
            {
                return Error("Failed to reject account");
            }
        }
        catch (Exception ex)
        {
            return Error($"Rejection failed: {ex.Message}");
        }
    }
    
    /// <summary>
    /// Get all pending accounts (for manager approval)
    /// </summary>
    public List<PendingAccountDTO> GetPendingAccounts()
    {
        var pendingAccounts = _accountRepo.GetPendingAccounts();
        var pendingAccountDTOs = new List<PendingAccountDTO>();
        
        foreach (var account in pendingAccounts)
        {
            var dto = new PendingAccountDTO
            {
                AccountID = account.AccountID,
                AccountType = account.AccountType,
                CustomerID = account.CustomerID,
                OpenedBy = account.OpenedBy,
                OpenedByRole = account.OpenedByRole,
                OpenDate = account.OpenDate,
                Status = account.Status
            };
            
            // Get customer name
            var customerRepo = new CustomerRepository();
            var customer = customerRepo.GetCustomerById(account.CustomerID);
            if (customer != null)
            {
                dto.CustomerName = customer.Custname;
            }
            
            // Get account-specific details
            if (account.AccountType == "FIXED-DEPOSIT")
            {
                var fdRepo = new FixedDepositAccountRepository();
                var fdAccount = fdRepo.GetFDAccountById(account.AccountID);
                if (fdAccount != null)
                {
                    dto.Amount = fdAccount.Amount ?? 0;
                    dto.MaturityAmount = fdAccount.MaturityAmount ?? 0;
                    dto.InterestRate = fdAccount.FD_ROI;
                    dto.StartDate = fdAccount.StartDate;
                    dto.EndDate = fdAccount.EndDate;
                }
            }
            else if (account.AccountType == "LOAN")
            {
                var loanRepo = new LoanAccountRepository();
                var loanAccount = loanRepo.GetLoanAccountById(account.AccountID);
                if (loanAccount != null)
                {
                    dto.LoanAmount = loanAccount.loan_amount ?? 0;
                    dto.EMI = loanAccount.Emi ?? 0;
                    dto.InterestRate = loanAccount.Ln_roi;
                    dto.Tenure = loanAccount.Tenure;
                    dto.StartDate = loanAccount.Start_date;
                }
            }
            
            pendingAccountDTOs.Add(dto);
        }
        
        return pendingAccountDTOs;
    }
    
    private AccountOperationResult Error(string message) => 
        new AccountOperationResult { IsSuccess = false, Message = message };
    
    private AccountOperationResult Success(string message) => 
        new AccountOperationResult { IsSuccess = true, Message = message };
}

/// <summary>
/// DTO for pending account approval
/// </summary>
public class PendingAccountDTO
{
    public string AccountID { get; set; }
    public string AccountType { get; set; }
    public string CustomerID { get; set; }
    public string CustomerName { get; set; }
    public string OpenedBy { get; set; }
    public string OpenedByRole { get; set; }
    public DateTime OpenDate { get; set; }
    public string Status { get; set; }
    
    // FD specific
    public decimal Amount { get; set; }
    public decimal MaturityAmount { get; set; }
    
    // Loan specific
    public decimal LoanAmount { get; set; }
    public decimal EMI { get; set; }
    
    // Common
    public decimal InterestRate { get; set; }
    public int Tenure { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
}
```

---

## ?? Manager Dashboard UI

### Pending Approvals Tab

```razor
<!-- Manager Dashboard ? Pending Approvals Tab -->
<div class="tab-pane fade" id="pending-approvals">
    <div class="card">
        <div class="card-header bg-warning text-white">
            <h5 class="mb-0">
                <i class="bi bi-clock-history me-2"></i>Pending Approvals
                <span class="badge bg-danger ms-2">@(ViewBag.PendingApprovalCount ?? 0)</span>
            </h5>
        </div>
        <div class="card-body">
            @if (ViewBag.PendingAccounts != null && ((List<PendingAccountDTO>)ViewBag.PendingAccounts).Count > 0)
            {
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-warning">
                            <tr>
                                <th>Application ID</th>
                                <th>Type</th>
                                <th>Customer</th>
                                <th>Amount</th>
                                <th>Interest Rate</th>
                                <th>Requested By</th>
                                <th>Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach (var app in (List<PendingAccountDTO>)ViewBag.PendingAccounts)
                            {
                                <tr>
                                    <td><strong>@app.AccountID</strong></td>
                                    <td>
                                        @if (app.AccountType == "FIXED-DEPOSIT")
                                        {
                                            <span class="badge bg-info">Fixed Deposit</span>
                                        }
                                        else
                                        {
                                            <span class="badge bg-warning text-dark">Loan</span>
                                        }
                                    </td>
                                    <td>
                                        <strong>@app.CustomerName</strong><br>
                                        <small class="text-muted">@app.CustomerID</small>
                                    </td>
                                    <td>
                                        @if (app.AccountType == "FIXED-DEPOSIT")
                                        {
                                            <span>? @app.Amount.ToString("N2")</span><br>
                                            <small class="text-muted">Maturity: ? @app.MaturityAmount.ToString("N2")</small>
                                        }
                                        else
                                        {
                                            <span>? @app.LoanAmount.ToString("N2")</span><br>
                                            <small class="text-muted">EMI: ? @app.EMI.ToString("N2")</small>
                                        }
                                    </td>
                                    <td>@app.InterestRate%</td>
                                    <td>
                                        <strong>@app.OpenedBy</strong><br>
                                        <small class="text-muted">@app.OpenedByRole</small>
                                    </td>
                                    <td>@app.OpenDate.ToString("dd/MM/yyyy")</td>
                                    <td>
                                        <button class="btn btn-sm btn-success" 
                                                onclick="approveAccount('@app.AccountID', '@app.AccountType')">
                                            <i class="bi bi-check-circle me-1"></i>Approve
                                        </button>
                                        <button class="btn btn-sm btn-danger ms-1" 
                                                onclick="showRejectModal('@app.AccountID', '@app.AccountType')">
                                            <i class="bi bi-x-circle me-1"></i>Reject
                                        </button>
                                    </td>
                                </tr>
                            }
                        </tbody>
                    </table>
                </div>
            }
            else
            {
                <div class="alert alert-info">
                    <i class="bi bi-info-circle me-2"></i>
                    No pending approvals at this time.
                </div>
            }
        </div>
    </div>
</div>
```

---

## ? Benefits of This Implementation

1. **? Better Control** - Manager reviews all high-value accounts
2. **? Audit Trail** - Clear record of who approved/rejected what
3. **? Customer Transparency** - Customers see application status
4. **? Employee Accountability** - Employees can track their submissions
5. **? Fraud Prevention** - Manager catches suspicious applications

---

## ?? Implementation Checklist

### Backend (Services & Repositories)
- [ ] Update `FixedDepositAccountService.cs` ? PENDING status
- [ ] Update `LoanAccountService.cs` ? PENDING status
- [ ] Create `AccountApprovalService.cs` with approval methods
- [ ] Update `AccountRepository.cs` ? Add approval/rejection methods
- [ ] Add `PendingAccountDTO` class

### Controller
- [ ] Add `ApproveAccount` POST action
- [ ] Add `RejectAccount` POST action
- [ ] Update `Index()` to load pending approvals for manager

### Manager Dashboard
- [ ] Add "Pending Approvals" tab
- [ ] Create approval table with account details
- [ ] Add Approve/Reject buttons
- [ ] Add rejection reason modal
- [ ] Add badge showing pending count

### Employee Dashboard
- [ ] Update success message for FD/Loan creation
- [ ] Show PENDING badge in accounts list

### Customer Dashboard
- [ ] Update account cards to show status badges
- [ ] Display different badges for PENDING/OPEN/REJECTED/CLOSED
- [ ] Disable transactions on non-OPEN accounts
- [ ] Show rejection reason if account rejected

### Testing
- [ ] Test FD creation ? Verify PENDING status
- [ ] Test Loan creation ? Verify PENDING status
- [ ] Test Manager approve ? Verify status changes to OPEN
- [ ] Test Manager reject ? Verify status changes to REJECTED
- [ ] Test Customer sees pending accounts
- [ ] Test Customer can only transact on OPEN accounts

---

**Next Step:** Start implementing Phase 1 (Backend Services) ??

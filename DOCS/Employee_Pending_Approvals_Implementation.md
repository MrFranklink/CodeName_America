# ?? Employee Dashboard - Department-Specific Pending Approvals Implementation

## ? **Status:** Implementation Complete - Just Add UI Tab

---

## ?? **What's Been Done:**

### **1. Controller Updates (`DashboardController.cs`)** ?

**Added department-specific pending approvals loading:**
```csharp
// For employee, load department info and customer list
if (role.ToUpper() == "EMPLOYEE")
{
    string deptId = Session["DeptId"]?.ToString() ?? "UNKNOWN";
    ViewBag.DeptId = deptId;
    
    // Load department-specific pending approvals
    // DEPT01 (Deposit Management) - can approve Fixed Deposits
    // DEPT02 (Loan Management) - can approve Loans
    if (deptId == "DEPT01")
    {
        // Only FD applications
        ViewBag.PendingAccounts = _accountService.GetPendingAccountsByType("FIXED-DEPOSIT");
        ViewBag.PendingApprovalCount = ViewBag.PendingAccounts != null ? ((List<PendingAccountDTO>)ViewBag.PendingAccounts).Count : 0;
    }
    else if (deptId == "DEPT02")
    {
        // Only Loan applications
        ViewBag.PendingAccounts = _accountService.GetPendingAccountsByType("LOAN");
        ViewBag.PendingApprovalCount = ViewBag.PendingAccounts != null ? ((List<PendingAccountDTO>)ViewBag.PendingAccounts).Count : 0;
    }
    else
    {
        // DEPT03 or other departments - no approval rights
        ViewBag.PendingAccounts = new List<PendingAccountDTO>();
        ViewBag.PendingApprovalCount = 0;
    }
    
    // Add account count statistic
    ViewBag.AccountCount = _accountService.GetTotalAccountCount();
    ViewBag.TransactionCount = 0;
}
```

**Updated ApproveAccount and RejectAccount to allow employees:**
```csharp
// POST: Dashboard/ApproveAccount
[HttpPost]
public ActionResult ApproveAccount(string accountId)
{
    string role = Session["Role"]?.ToString().ToUpper();
    string referenceId = Session["ReferenceID"]?.ToString();
    string deptId = Session["DeptId"]?.ToString();
    
    // Check authorization: Manager OR Employee with proper department
    bool isAuthorized = false;
    string accountType = "";
    
    try
    {
        // Get account details to check type
        var account = _accountService.GetAccountById(accountId);
        if (account == null)
        {
            TempData["ErrorMessage"] = "Account not found.";
            return RedirectToAction("Index");
        }
        
        accountType = account.AccountType;
        
        // Authorization logic
        if (role == "MANAGER")
        {
            isAuthorized = true;
        }
        else if (role == "EMPLOYEE")
        {
            // DEPT01 can approve Fixed Deposits
            if (deptId == "DEPT01" && accountType == "FIXED-DEPOSIT")
            {
                isAuthorized = true;
            }
            // DEPT02 can approve Loans
            else if (deptId == "DEPT02" && accountType == "LOAN")
            {
                isAuthorized = true;
            }
        }
        
        if (!isAuthorized)
        {
            TempData["ErrorMessage"] = $"Access denied. Your department ({deptId}) cannot approve {accountType} accounts.";
            return RedirectToAction("Index");
        }

        var result = _accountService.ApproveAccount(accountId, referenceId);

        if (result.IsSuccess)
        {
            TempData["SuccessMessage"] = result.Message;
        }
        else
        {
            TempData["ErrorMessage"] = result.Message;
        }
    }
    catch (Exception ex)
    {
        TempData["ErrorMessage"] = "Approval failed: " + ex.Message;
    }

    return RedirectToAction("Index");
}
```

---

## ?? **What You Need to Add to EmployeeDashboard.cshtml:**

### **Step 1: Add "Pending Approvals" Tab Button**

**Location:** In the `<ul class="nav nav-tabs mb-4" id="employeeTabs">` section, **after** the `view-accounts` tab and **before** the closing `</ul>` tag.

```razor
@if (isDept01 || isDept02)
{
    <li class="nav-item">
        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#pending-approvals" type="button">
            <i class="bi bi-hourglass-split me-1"></i>Pending
            @if (ViewBag.PendingApprovalCount != null && ViewBag.PendingApprovalCount > 0)
            {
                <span class="badge bg-danger ms-1">@ViewBag.PendingApprovalCount</span>
            }
        </button>
    </li>
}
```

### **Step 2: Add "Pending Approvals" Tab Content**

**Location:** In the `<div class="tab-content">` section, **after** the `view-accounts` tab pane and **before** the closing `</div>` of `tab-content`.

```razor
@if (isDept01 || isDept02)
{
    <!-- Pending Approvals Tab (Department-Specific) -->
    <div class="tab-pane fade" id="pending-approvals">
        <div class="card">
            <div class="card-header bg-warning text-dark">
                <h5 class="mb-0">
                    <i class="bi bi-hourglass-split me-2"></i>Pending Approvals - @ViewBag.DeptId
                    @if (ViewBag.PendingApprovalCount != null && ViewBag.PendingApprovalCount > 0)
                    {
                        <span class="badge bg-danger ms-2">@ViewBag.PendingApprovalCount</span>
                    }
                </h5>
            </div>
            <div class="card-body">
                @if (ViewBag.PendingAccounts != null && ((List<PendingAccountDTO>)ViewBag.PendingAccounts).Count > 0)
                {
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle me-2"></i>
                        @if (isDept01)
                        {
                            <strong>Deposit Management:</strong> Review and approve/reject Fixed Deposit applications.
                        }
                        else if (isDept02)
                        {
                            <strong>Loan Management:</strong> Review and approve/reject Loan applications.
                        }
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-warning">
                                <tr>
                                    <th>App ID</th>
                                    <th>Type</th>
                                    <th>Customer</th>
                                    <th>Amount</th>
                                    <th>Interest</th>
                                    <th>By</th>
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
                                                <span class="badge bg-info">FD</span>
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
                                        <td>@app.InterestRate% p.a.</td>
                                        <td>
                                            <strong>@app.OpenedBy</strong><br>
                                            <small class="text-muted">@app.OpenedByRole</small>
                                        </td>
                                        <td>@app.OpenDate.ToString("dd/MM/yyyy")</td>
                                        <td>
                                            <!-- Approve Button -->
                                            <form method="post" action="@Url.Action("ApproveAccount", "Dashboard")" style="display:inline;">
                                                <input type="hidden" name="accountId" value="@app.AccountID" />
                                                <button type="submit" class="btn btn-sm btn-success" 
                                                        onclick="return confirm('Approve this @(app.AccountType == "FIXED-DEPOSIT" ? "Fixed Deposit" : "Loan") application?');">
                                                    <i class="bi bi-check-circle me-1"></i>Approve
                                                </button>
                                            </form>
                                            
                                            <!-- Reject Button -->
                                            <button class="btn btn-sm btn-danger ms-1" 
                                                    onclick="showRejectModal('@app.AccountID', '@(app.AccountType == "FIXED-DEPOSIT" ? "Fixed Deposit" : "Loan")')">
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
                    <div class="alert alert-success">
                        <i class="bi bi-check-circle me-2"></i>
                        No pending approvals for your department (@ViewBag.DeptId). All applications have been processed!
                    </div>
                }
            </div>
        </div>
    </div>
}
```

### **Step 3: Add Rejection Modal (Before closing `</div>` of main container)**

**Location:** After all tab content, before the closing `</div>` of the main container, **just before** the `@section scripts` section.

```razor
<!-- Rejection Modal -->
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">
                    <i class="bi bi-x-circle me-2"></i>Reject Application
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="@Url.Action("RejectAccount", "Dashboard")">
                <div class="modal-body">
                    <input type="hidden" name="accountId" id="rejectAccountId" />
                    
                    <div class="alert alert-warning">
                        <i class="bi bi-exclamation-triangle me-2"></i>
                        You are about to reject <strong id="rejectAccountType"></strong> application 
                        <strong id="rejectAccountIdDisplay"></strong>
                    </div>
                    
                    <div class="mb-3">
                        <label for="rejectionReason" class="form-label">
                            <strong>Rejection Reason</strong> <span class="text-danger">*</span>
                        </label>
                        <textarea name="rejectionReason" id="rejectionReason" 
                                  class="form-control" rows="4" 
                                  placeholder="Enter reason for rejection (required)" 
                                  required></textarea>
                        <small class="text-muted">This reason will be visible to the customer</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-x-circle me-2"></i>Reject Application
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
```

### **Step 4: Add JavaScript Function to Scripts Section**

**Location:** In the `@section scripts { ... }` section, **after** the existing JavaScript code and **before** the closing script tag.

```javascript
// Show reject modal with application details
function showRejectModal(accountId, accountType) {
    document.getElementById('rejectAccountId').value = accountId;
    document.getElementById('rejectAccountIdDisplay').textContent = accountId;
    document.getElementById('rejectAccountType').textContent = accountType;
    document.getElementById('rejectionReason').value = '';
    
    var modal = new bootstrap.Modal(document.getElementById('rejectModal'));
    modal.show();
}
```

---

## ?? **Department-Specific Approval Matrix:**

| Account Type | DEPT01 (Deposit) | DEPT02 (Loan) | DEPT03 (HR) | Manager |
|--------------|------------------|---------------|-------------|---------|
| Fixed Deposit | ? Can Approve/Reject | ? Cannot | ? Cannot | ? Can Approve/Reject |
| Loan | ? Cannot | ? Can Approve/Reject | ? Cannot | ? Can Approve/Reject |

---

## ?? **Testing Scenarios:**

### **Test 1: DEPT01 Employee - FD Approval**
```
1. Login as DEPT01 employee (Deposit Management)
2. Customer applies for FD (?50,000, 12 months)
3. DEPT01 dashboard shows "Pending (1)" badge
4. Click "Pending" tab
5. See FD application in table
6. Click "? Approve"
7. Success! FD approved
8. Badge count reduces to 0
9. Customer sees green "Active" FD card
```

### **Test 2: DEPT01 Cannot Approve Loans**
```
1. Login as DEPT01 employee
2. Customer applies for Loan (?100,000)
3. DEPT01 dashboard shows NO badge (shouldn't see loan apps)
4. Click "Pending" tab
5. Should see: "No pending approvals for your department"
6. Manager or DEPT02 must approve the loan
```

### **Test 3: DEPT02 Employee - Loan Approval**
```
1. Login as DEPT02 employee (Loan Management)
2. Customer applies for Loan (?100,000, 60 months)
3. DEPT02 dashboard shows "Pending (1)" badge
4. Click "Pending" tab
5. See Loan application in table
6. Click "? Reject"
7. Modal opens
8. Enter reason: "Insufficient income documentation"
9. Click Reject
10. Success! Loan rejected
11. Badge count reduces to 0
12. Customer sees red "Rejected" Loan card
```

### **Test 4: DEPT02 Cannot Approve FDs**
```
1. Login as DEPT02 employee
2. Customer applies for FD (?50,000)
3. DEPT02 dashboard shows NO badge (shouldn't see FD apps)
4. Click "Pending" tab
5. Should see: "No pending approvals for your department"
6. Manager or DEPT01 must approve the FD
```

### **Test 5: DEPT03 Has No Approval Rights**
```
1. Login as DEPT03 employee (HR)
2. Customer applies for FD or Loan
3. DEPT03 dashboard shows NO "Pending" tab (tab doesn't appear)
4. HR employees can only view customers and accounts
5. Cannot approve or reject anything
```

---

## ?? **Database Audit Trail:**

When an employee approves/rejects, the system records:

```sql
-- After Employee Approval:
SELECT 
    AccountID,
    AccountType,
    Status,           -- Changed to 'OPEN'
    ApprovedBy,       -- Set to Employee ID (e.g., EMP00001)
    ApprovalDate,     -- Set to current timestamp
    OpenedBy,         -- Still shows who created it (could be CUSTOMER)
    OpenedByRole      -- Still shows 'CUSTOMER' if self-applied
FROM Account
WHERE AccountID = 'FD00006';

-- Example Result:
-- AccountID: FD00006
-- AccountType: FIXED-DEPOSIT
-- Status: OPEN
-- ApprovedBy: EMP00001 (DEPT01 employee)
-- ApprovalDate: 2025-01-17 10:30:00
-- OpenedBy: MLA00009 (customer who applied)
-- OpenedByRole: CUSTOMER
```

```sql
-- After Employee Rejection:
SELECT 
    AccountID,
    AccountType,
    Status,              -- Changed to 'REJECTED'
    RejectionReason,     -- Set to employee's entered reason
    ApprovedBy,          -- Remains NULL
    OpenedBy,            -- Still shows who created it
    OpenedByRole         -- Still shows 'CUSTOMER' if self-applied
FROM Account
WHERE AccountID = 'LN00005';

-- Example Result:
-- AccountID: LN00005
-- AccountType: LOAN
-- Status: REJECTED
-- RejectionReason: Insufficient income documentation. Please provide 6 months of salary slips.
-- ApprovedBy: NULL
-- OpenedBy: MLA00009
-- OpenedByRole: CUSTOMER
```

---

## ? **Success Checklist:**

After adding the UI changes:

- [ ] Build solution (should succeed)
- [ ] Test DEPT01 employee login
- [ ] Customer applies for FD
- [ ] DEPT01 sees "Pending (1)" badge
- [ ] DEPT01 can approve FD
- [ ] DEPT01 cannot see Loan applications
- [ ] Test DEPT02 employee login
- [ ] Customer applies for Loan
- [ ] DEPT02 sees "Pending (1)" badge
- [ ] DEPT02 can approve Loan
- [ ] DEPT02 cannot see FD applications
- [ ] Test DEPT03 employee
- [ ] DEPT03 has no "Pending" tab
- [ ] Manager can see all pending applications (FD + Loan)
- [ ] Database records ApprovedBy correctly

---

## ?? **Summary:**

? **Controller changes:** Complete  
? **Department filtering:** Implemented  
? **Authorization logic:** Added  
? **Audit trail:** Configured  

?? **Next step:** Add the 4 code blocks above to `EmployeeDashboard.cshtml`  
?? **Time needed:** 5 minutes  

---

**After adding these changes, employees will have department-specific approval capabilities!** ??

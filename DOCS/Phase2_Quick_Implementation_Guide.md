# ? Phase 2 - Manager Dashboard: Final Implementation

## ?? Quick Implementation - Copy & Paste Ready

### Backend: ? ALREADY DONE
- `DashboardController.cs` - Updated with Approve/Reject actions ?
- Service methods added ?

---

## ?? Frontend: MANUAL STEPS REQUIRED

### Step 1: Add "Pending Approvals" Tab Button

**File:** `Bank_App/Views/Dashboard/ManagerDashboard.cshtml`

**Location:** Find the line with `<button class="nav-link" data-bs-toggle="tab" data-bs-target="#manage-accounts"`

**Add this AFTER the "Manage" tab button (before the `</ul>`):**

```razor
<li class="nav-item">
    <button class="nav-link" data-bs-toggle="tab" data-bs-target="#pending-approvals" type="button">
        <i class="bi bi-hourglass-split me-1"></i>Pending
        @if (ViewBag.PendingApprovalCount != null && ViewBag.PendingApprovalCount > 0)
        {
            <span class="badge bg-danger ms-1">@ViewBag.PendingApprovalCount</span>
        }
    </button>
</li>
```

---

### Step 2: Add Tab Content

**Location:** Find `<div class="tab-pane fade" id="manage-accounts">` section

**Add this AFTER the closing `</div>` of "manage-accounts" tab (before the final `</div>` of tab-content):**

```razor
<!-- Pending Approvals Tab -->
<div class="tab-pane fade" id="pending-approvals">
    <div class="card">
        <div class="card-header bg-warning text-dark">
            <h5 class="mb-0">
                <i class="bi bi-hourglass-split me-2"></i>Pending Approvals
                @if (ViewBag.PendingApprovalCount != null && ViewBag.PendingApprovalCount > 0)
                {
                    <span class="badge bg-danger ms-2">@ViewBag.PendingApprovalCount</span>
                }
            </h5>
        </div>
        <div class="card-body">
            @if (ViewBag.PendingAccounts != null && ((List<PendingAccountDTO>)ViewBag.PendingAccounts).Count > 0)
            {
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
                                            <span>?@app.Amount.ToString("N0")</span>
                                        }
                                        else
                                        {
                                            <span>?@app.LoanAmount.ToString("N0")</span><br>
                                            <small class="text-muted">EMI: ?@app.EMI.ToString("N0")</small>
                                        }
                                    </td>
                                    <td>@app.InterestRate%</td>
                                    <td>
                                        <small>@app.OpenedBy</small>
                                    </td>
                                    <td>@app.OpenDate.ToString("dd/MM")</td>
                                    <td>
                                        <form method="post" action="@Url.Action("ApproveAccount", "Dashboard")" style="display:inline;">
                                            <input type="hidden" name="accountId" value="@app.AccountID" />
                                            <button type="submit" class="btn btn-sm btn-success" 
                                                    onclick="return confirm('Approve?');">
                                                <i class="bi bi-check"></i>
                                            </button>
                                        </form>
                                        <button class="btn btn-sm btn-danger" 
                                                onclick="showRejectModal('@app.AccountID')">
                                            <i class="bi bi-x"></i>
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
                    No pending approvals!
                </div>
            }
        </div>
    </div>
</div>
```

---

### Step 3: Add Rejection Modal

**Location:** Find `@section scripts {` 

**Add this BEFORE `@section scripts {`:**

```razor
<!-- Reject Modal -->
<div class="modal fade" id="rejectModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title"><i class="bi bi-x-circle me-2"></i>Reject Application</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form method="post" action="@Url.Action("RejectAccount", "Dashboard")">
                <div class="modal-body">
                    <input type="hidden" name="accountId" id="rejectAccountId" />
                    <div class="mb-3">
                        <label class="form-label"><strong>Rejection Reason *</strong></label>
                        <textarea name="rejectionReason" class="form-control" rows="3" 
                                  placeholder="Enter reason..." required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">Reject</button>
                </div>
            </form>
        </div>
    </div>
</div>
```

---

### Step 4: Add JavaScript Function

**Location:** Inside `@section scripts {`, add this at the END (before closing `</script>`):**

```javascript
// Show reject modal
function showRejectModal(accountId) {
    document.getElementById('rejectAccountId').value = accountId;
    new bootstrap.Modal(document.getElementById('rejectModal')).show();
}
```

---

## ? Build & Test

```bash
# 1. Run SQL script first
SQL_Scripts/Add_Approval_Workflow_Columns.sql

# 2. Update Entity Framework
# - Open Model1.edmx
# - Right-click ? Update from Database
# - Select Account table
# - Rebuild

# 3. Build solution
F6 or Ctrl+Shift+B

# 4. Test
# - Login as Manager
# - Check "Pending" tab
# - Should see badge with count
# - Test Approve ? Status = OPEN
# - Test Reject ? Enter reason ? Status = REJECTED
```

---

## ?? Phase 3 Preview (Customer Dashboard)

Next, we'll update Customer Dashboard to show status badges:
- ?? PENDING ? "Awaiting Approval"
- ?? OPEN ? "Active"
- ?? REJECTED ? "Rejected" + reason

---

**Current Status:**  
? Backend Complete  
? Manager Dashboard - Ready to add  
?? Customer Dashboard - Next phase

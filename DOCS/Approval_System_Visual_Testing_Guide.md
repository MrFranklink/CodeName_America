# ?? Approval System - Quick Visual Testing Guide

## ?? Setup (One-Time)

### 1. Run SQL Script
```sql
-- In SSMS, run this file:
SQL_Scripts/Add_Approval_Workflow_Columns.sql
```

### 2. Update Entity Framework
```
1. Open DB/Model1.edmx
2. Right-click canvas ? "Update Model from Database"
3. Refresh ? Tables ? Check "Account"
4. Finish ? Save ? Rebuild DB project
```

### 3. Add Manager Dashboard Tab (5 Minutes)
```
Open: Bank_App/Views/Dashboard/ManagerDashboard.cshtml
Follow: DOCS/Phase2_Quick_Implementation_Guide.md
Copy-paste 4 code blocks (tab, content, modal, script)
```

---

## ?? Test Scenario 1: Fixed Deposit Application

### A. Create FD Application (Employee)

**Login:**
```
Username: emp001
Password: emp001
```

**Steps:**
1. Click "Open FD" tab
2. Fill form:
   - Customer ID: `MLA00001`
   - Amount: `50000`
   - Start Date: Today
   - Tenure: `12` months
3. Click "Open Fixed Deposit"

**Expected Result:**
```
? Success: "Fixed Deposit application submitted successfully! 
            Application ID: FD00001, Amount: Rs. 50,000.00, 
            Interest Rate: 7%. ? Awaiting manager approval."
```

---

### B. Check Status (Customer)

**Login:**
```
Username: john (or your customer username)
Password: john123
```

**What You Should See:**

**1. Alert at Top (Yellow):**
```
?? Pending Applications: You have 1 application(s) awaiting manager approval.
   [FD00001 (FD)]
```

**2. Account Card (Yellow Border):**
```
???????????????????????????????????
? ?? Fixed Deposit     [? Pending] ?
? FD00001                         ?
?                                 ?
? ?? Awaiting Approval            ?
? Your application is under       ?
? review by our manager. You'll   ?
? be notified once it's approved. ?
?                                 ?
? Amount: ?50,000.00              ?
? Interest: 7% p.a.               ?
???????????????????????????????????
```

---

### C. Approve Application (Manager)

**Login:**
```
Username: mgr001
Password: mgr001
```

**Steps:**
1. Click "Pending" tab (should show badge with "1")
2. Find FD00001 in table
3. Click green "?" (Approve) button
4. Confirm approval

**Expected Result:**
```
? Success: "Fixed Deposit account FD00001 approved successfully! 
            Customer can now use this account."
```

**Verify:**
- Badge count decreases to 0
- FD00001 disappears from pending list

---

### D. Verify Approved Status (Customer)

**Login:** Customer again

**What You Should See:**

**1. No Yellow Alert** ?

**2. Account Card (Green Border):**
```
???????????????????????????????????
? ?? Fixed Deposit      [? Active] ?
? FD00001                         ?
?                                 ?
? ?52,600.00                      ?
? Maturity | 7% p.a.              ?
???????????????????????????????????
```

**3. Full Details Visible** ?
- Maturity amount calculated
- Interest rate shown
- Account is fully functional

---

## ?? Test Scenario 2: Loan Rejection

### A. Create Loan Application (Employee DEPT02)

**Login:**
```
Username: emp002 (Loan Management)
Password: emp002
```

**Steps:**
1. Click "Open Loan" tab
2. Fill form:
   - Customer ID: `MLA00002`
   - Monthly Salary: `30000`
   - Loan Amount: `500000`
   - Tenure: `60` months
   - Start Date: Today
3. Wait for validation (should show "Eligible!")
4. Click "Sanction Loan"

**Expected Result:**
```
? Success: "Loan application submitted successfully! 
            Application ID: LN00001, Loan Amount: Rs. 5,00,000.00, 
            Interest Rate: 9.5%, Tenure: 60 months, EMI: Rs. X,XXX.XX. 
            ? Awaiting manager approval."
```

---

### B. Check Status (Customer)

**Login:** Customer (MLA00002)

**Should See:**
```
?? Pending Applications: You have 1 application(s) awaiting manager approval.
   [LN00001 (Loan)]

???????????????????????????????????
? ?? Loan              [? Pending] ?
? LN00001                         ?
?                                 ?
? ?? Awaiting Approval            ?
? ...                             ?
? Loan: ?5,00,000.00              ?
? EMI: ?X,XXX.XX                  ?
? Interest: 9.5% p.a.             ?
???????????????????????????????????
```

---

### C. Reject Application (Manager)

**Login:** Manager

**Steps:**
1. Click "Pending" tab
2. Find LN00001
3. Click red "?" (Reject) button
4. Modal opens - Enter reason:
   ```
   Insufficient credit history. Please reapply after 6 months with 
   updated salary documents.
   ```
5. Click "Reject"

**Expected Result:**
```
? Success: "Loan account LN00001 rejected. 
            Reason: Insufficient credit history..."
```

---

### D. Verify Rejection (Customer)

**Login:** Customer again

**What You Should See:**

**1. Red Alert at Top:**
```
? Application Rejected: 1 application(s) were not approved. 
   Please check your account cards below for details.
   [LN00001 (Loan)]
```

**2. Account Card (Red Border):**
```
???????????????????????????????????
? ?? Loan             [? Rejected] ?
? LN00001                         ?
?                                 ?
? ? Application Rejected          ?
? Your application was not        ?
? approved. Please contact        ?
? customer service for more       ?
? information.                    ?
???????????????????????????????????
```

**3. No Account Details** ?
- No loan amount shown
- No EMI shown
- Account cannot be used

---

## ?? Status Badge Reference

### Visual Guide

| Status | Badge | Border | Customer Sees |
|--------|-------|--------|---------------|
| **PENDING** | ?? `? Pending` | Yellow | "Awaiting Approval" message + application details |
| **OPEN** | ?? `? Active` | Green/Blue | Full account details, can transact |
| **REJECTED** | ?? `? Rejected` | Red | "Application Rejected" message |
| **CLOSED** | ? `?? Closed` | Gray | "Account Closed" with date |

---

## ?? Quick Verification Checklist

### Customer Dashboard
- [ ] Yellow alert shows for pending accounts
- [ ] Red alert shows for rejected accounts
- [ ] Pending cards show yellow border + hourglass icon
- [ ] Rejected cards show red border + X icon
- [ ] Approved cards show green/blue border + check icon
- [ ] Application details visible on pending cards
- [ ] No details shown on rejected cards
- [ ] Full details shown on approved cards

### Employee Dashboard
- [ ] "View Accounts" tab shows all accounts
- [ ] Status column has colored badges with icons
- [ ] Can see which applications are pending at a glance

### Manager Dashboard
- [ ] "Pending" tab shows badge with count
- [ ] Table lists all pending FD/Loan applications
- [ ] Shows customer name, amount, interest, date
- [ ] Green "Approve" button works
- [ ] Red "Reject" button opens modal
- [ ] Modal requires rejection reason
- [ ] After action, pending count updates

---

## ?? Troubleshooting

### Issue: Can't see Pending tab in Manager Dashboard
**Solution:** Follow `DOCS/Phase2_Quick_Implementation_Guide.md` to add the tab (5 min task)

### Issue: Build errors after SQL script
**Solution:** Update Entity Framework model:
```
1. Open DB/Model1.edmx
2. Right-click ? Update Model from Database
3. Refresh Tables ? Check "Account"
4. Finish ? Save ? Rebuild DB project
```

### Issue: Status always shows "OPEN" instead of "PENDING"
**Solution:** SQL script not run yet. Run `Add_Approval_Workflow_Columns.sql` first.

### Issue: Can't approve/reject (button doesn't work)
**Solution:** Check console for errors. Ensure Account table has new columns.

---

## ?? Expected Screenshots

### Customer - Pending State
```
[Yellow Alert Bar]
?? Pending Applications: You have 1 application(s)...

[Account Card - Yellow Border]
???????????????
? FD | ? Pending?
? FD00001     ?
? Awaiting... ?
???????????????
```

### Customer - Approved State
```
[No Alert]

[Account Card - Green Border]
???????????????
? FD | ? Active?
? FD00001     ?
? ?52,600     ?
???????????????
```

### Customer - Rejected State
```
[Red Alert Bar]
? Application Rejected: 1 application(s)...

[Account Card - Red Border]
???????????????
? FD | ? Rejected?
? FD00001     ?
? Rejected... ?
???????????????
```

### Manager - Pending Approvals
```
[Tab with Badge]
[Pending (2)]

[Table]
FD00001 | FD | John | ?50,000 | [?] [?]
LN00001 | Loan | Jane | ?5L | [?] [?]
```

---

## ?? Success Criteria

? **Test Passed If:**
1. Employee can create FD/Loan ? Status = PENDING
2. Customer sees yellow alert + pending card
3. Manager sees pending tab with count badge
4. Manager can approve ? Customer sees green active card
5. Manager can reject ? Customer sees red rejected card
6. All status badges have correct colors and icons
7. No build errors or console errors

---

**Testing Time:** ~10 minutes  
**Setup Time:** ~10 minutes (one-time)  
**Total Time:** ~20 minutes for complete workflow test

**Happy Testing! ??**

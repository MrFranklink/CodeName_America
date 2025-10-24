# ?? Employee Approval System - Quick Testing Guide

## ? **5-Minute Testing Workflow**

---

## ?? **Test Setup (One-Time)**

### **Required Test Accounts:**

```
Customer:
- Username: mla00001_usr (or similar)
- Password: (your customer password)
- Role: CUSTOMER

DEPT01 Employee (Deposit Management):
- Username: emp00001_usr (or similar)
- Password: (your employee password)
- Role: EMPLOYEE
- Department: DEPT01

DEPT02 Employee (Loan Management):
- Username: emp00002_usr (or similar)
- Password: (your employee password)
- Role: EMPLOYEE
- Department: DEPT02

Manager:
- Username: mgr00001_usr (or similar)
- Password: (your manager password)
- Role: MANAGER
```

---

## ? **Quick Test 1: DEPT01 Approves FD (2 minutes)**

### **Step 1: Customer Applies for FD**
1. Login as **Customer**
2. Go to "Apply for FD" section
3. Fill form:
   - Amount: **?50,000**
   - Start Date: **Today**
   - Tenure: **12 months**
4. Click **"Apply for Fixed Deposit"**
5. See yellow "Pending Approval" card
6. **Logout**

### **Step 2: DEPT01 Employee Approves**
1. Login as **DEPT01 Employee**
2. Look at tabs ? See **"Pending (1)"** badge ?
3. Click **"Pending"** tab
4. See FD application in table
5. Click **"? Approve"** button
6. Confirm approval
7. See success message
8. Badge count updates to **0** ?
9. **Logout**

### **Step 3: Customer Verifies**
1. Login as **Customer**
2. See FD card changed to **green "Active"** ?
3. **Test 1 PASSED!** ??

---

## ? **Quick Test 2: DEPT02 Rejects Loan (2 minutes)**

### **Step 1: Customer Applies for Loan**
1. Login as **Customer**
2. Go to "Apply for Loan" section
3. Fill form:
   - Loan Amount: **?100,000**
   - Start Date: **Today**
   - Tenure: **60 months**
   - Salary: **?30,000**
4. Click **"Apply for Loan"**
5. See yellow "Pending Approval" card
6. **Logout**

### **Step 2: DEPT02 Employee Rejects**
1. Login as **DEPT02 Employee**
2. Look at tabs ? See **"Pending (1)"** badge ?
3. Click **"Pending"** tab
4. See Loan application in table
5. Click **"? Reject"** button
6. Modal opens
7. Enter reason: **"Insufficient documentation. Please provide salary slips."**
8. Click **"Reject Application"**
9. See success message
10. Badge count updates to **0** ?
11. **Logout**

### **Step 3: Customer Verifies**
1. Login as **Customer**
2. See Loan card changed to **red "Rejected"** ?
3. See rejection reason displayed ?
4. **Test 2 PASSED!** ??

---

## ? **Quick Test 3: Wrong Department (1 minute)**

### **Test DEPT01 Cannot See Loans**
1. Customer applies for **Loan**
2. Login as **DEPT01 Employee** (Deposit Management)
3. Look at tabs ? **NO badge** ?
4. Click **"Pending"** tab
5. See: **"No pending approvals for your department (DEPT01)"** ?
6. **Test 3a PASSED!** ??

### **Test DEPT02 Cannot See FDs**
1. Customer applies for **FD**
2. Login as **DEPT02 Employee** (Loan Management)
3. Look at tabs ? **NO badge** ?
4. Click **"Pending"** tab
5. See: **"No pending approvals for your department (DEPT02)"** ?
6. **Test 3b PASSED!** ??

---

## ? **Quick Test 4: Manager Can Approve All (2 minutes)**

### **Step 1: Customer Applies for Both**
1. Login as **Customer**
2. Apply for **FD** (?50,000, 12 months)
3. Apply for **Loan** (?100,000, 60 months, salary ?30,000)
4. See **2 pending cards** ?
5. **Logout**

### **Step 2: Manager Approves Both**
1. Login as **Manager**
2. Look at tabs ? See **"Pending (2)"** badge ?
3. Click **"Pending"** tab
4. See **both FD and Loan** applications ?
5. Approve FD ? badge becomes **"Pending (1)"** ?
6. Approve Loan ? badge disappears ?
7. **Logout**

### **Step 3: Customer Verifies**
1. Login as **Customer**
2. See **both cards are green "Active"** ?
3. **Test 4 PASSED!** ??

---

## ? **Quick Test 5: DEPT03 Has No Access (30 seconds)**

1. Login as **DEPT03 Employee** (HR)
2. Look at tabs ? **NO "Pending" tab** at all ?
3. DEPT03 can only view customers and accounts
4. **Test 5 PASSED!** ??

---

## ?? **All Tests Passed?**

If all 5 quick tests pass, the **Employee Approval System is 100% working!** ?

---

## ?? **Common Issues & Fixes:**

### **Issue 1: Badge Not Showing**
**Symptom:** No "Pending (1)" badge appears  
**Cause:** ViewBag.PendingApprovalCount is NULL  
**Fix:** Check `DashboardController.cs` ? `Index()` method ? Employee section  
**Solution:** Ensure `GetPendingAccountsByAccountType()` is called

### **Issue 2: Cannot Approve**
**Symptom:** Click "Approve" ? Error: "Access denied"  
**Cause:** Department authorization check failing  
**Fix:** Check Session["DeptId"] is set correctly (DEPT01 or DEPT02)  
**Solution:** Verify employee record has correct DeptId in database

### **Issue 3: Modal Not Opening**
**Symptom:** Click "Reject" ? Nothing happens  
**Cause:** JavaScript function not found  
**Fix:** Check `EmployeeDashboard.cshtml` ? `@section scripts`  
**Solution:** Ensure `showRejectModal()` function is present

### **Issue 4: Rejection Without Reason**
**Symptom:** Can submit rejection with empty reason  
**Cause:** Form validation not working  
**Fix:** Check modal form has `required` attribute on textarea  
**Solution:** Add `required` to `rejectionReason` textarea

### **Issue 5: Badge Not Updating**
**Symptom:** Badge still shows "Pending (1)" after approval  
**Cause:** Page not refreshing after approval  
**Fix:** Check `ApproveAccount()` returns `RedirectToAction("Index")`  
**Solution:** Ensure method ends with `return RedirectToAction("Index");`

---

## ?? **Database Verification Queries:**

### **Check Pending Applications:**
```sql
SELECT 
    AccountID,
    AccountType,
    CustomerID,
    Status,
    OpenedBy,
    OpenedByRole,
    ApprovedBy,
    RejectionReason
FROM Account
WHERE Status = 'PENDING';
```

### **Check Approved Applications:**
```sql
SELECT 
    AccountID,
    AccountType,
    Status,
    ApprovedBy,
    ApprovalDate
FROM Account
WHERE Status = 'OPEN'
AND ApprovedBy IS NOT NULL;
```

### **Check Rejected Applications:**
```sql
SELECT 
    AccountID,
    AccountType,
    Status,
    RejectionReason
FROM Account
WHERE Status = 'REJECTED';
```

---

## ?? **Success Criteria:**

After testing, verify:

- ? DEPT01 can approve/reject **only FD applications**
- ? DEPT02 can approve/reject **only Loan applications**
- ? DEPT03 has **no approval capabilities**
- ? Manager can approve/reject **all applications**
- ? Badge shows **correct pending count**
- ? Badge **updates after action**
- ? Rejection modal **requires reason**
- ? Customer sees **status changes** (Pending ? Active/Rejected)
- ? Database records **ApprovedBy** correctly
- ? Database records **RejectionReason** correctly

---

## ?? **Ready to Test?**

1. ? Build successful
2. ? Run application
3. ? Follow 5 quick tests above
4. ? Verify all criteria
5. ? Celebrate! ??

---

**Total Testing Time:** ~10 minutes  
**Last Updated:** January 17, 2025  
**Status:** Ready for Testing ?


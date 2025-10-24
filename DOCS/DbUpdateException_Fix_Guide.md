# ?? URGENT FIX: DbUpdateException - Missing Columns

## ? **Current Error:**

```
System.Data.Entity.Infrastructure.DbUpdateException
An error occurred while updating the entries. See the inner exception for details.
```

**Cause:** Entity Framework model doesn't have the new approval workflow columns yet.

---

## ? **SOLUTION: 2-Step Fix (5 minutes)**

### **Step 1: Verify SQL Script Was Run**

**Open SSMS** and run this check:

```sql
USE Banking_Details;
GO

-- Check if columns exist
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Account'
  AND COLUMN_NAME IN ('RejectionReason', 'ApprovedBy', 'ApprovalDate')
ORDER BY COLUMN_NAME;
```

**Expected Result:**
```
ApprovalDate      datetime    YES
ApprovedBy        varchar     YES
RejectionReason   nvarchar    YES
```

**If NO ROWS returned:**
- ? SQL script NOT run yet
- ? **Solution:** Run `SQL_Scripts/Add_Approval_Workflow_Columns.sql` in SSMS
- Then continue to Step 2

**If 3 ROWS returned:**
- ? Columns exist in database
- ? Entity Framework model not updated
- ? Continue to Step 2

---

### **Step 2: Update Entity Framework Model**

#### **Option A: Visual Studio Designer (Recommended)**

1. **Open Model:**
   - Solution Explorer ? `DB` project ? `Model1.edmx`
   - Double-click to open designer

2. **Update Model:**
   - **Right-click** on canvas (empty area)
   - **Select:** "Update Model from Database..."
   
3. **Wizard Opens:**
   ```
   ????????????????????????????????????
   ? Update Model Wizard              ?
   ????????????????????????????????????
   ? Tabs: [Add] [Refresh] [Delete]   ?
   ?                                  ?
   ? Click "Refresh" tab              ?
   ????????????????????????????????????
   ```

4. **Select Account Table:**
   ```
   ????????????????????????????????????
   ? Refresh Tab                      ?
   ????????????????????????????????????
   ? ? Tables                         ?
   ?   ? Account  ? CHECK THIS BOX  ?
   ?   ? Customer                     ?
   ?   ? Employee                     ?
   ?   ...                            ?
   ?                                  ?
   ?           [Finish]               ?
   ????????????????????????????????????
   ```

5. **Click Finish**
   - Wait for model to update
   - Save (Ctrl+S)

6. **Rebuild DB Project:**
   ```
   Solution Explorer
   ? Right-click "DB" project
   ? Rebuild
   ```

7. **Rebuild Solution:**
   ```
   Build ? Rebuild Solution
   (or Ctrl+Shift+B)
   ```

---

#### **Option B: Manual Update (If Wizard Fails)**

If the wizard doesn't work, manually add properties to `Account.cs`:

1. **Open:** `DB/Account.cs`

2. **Find the Account class:**
   ```csharp
   public partial class Account
   {
       public string AccountID { get; set; }
       public string AccountType { get; set; }
       public string CustomerID { get; set; }
       public string OpenedBy { get; set; }
       public string OpenedByRole { get; set; }
       public System.DateTime OpenDate { get; set; }
       public string Status { get; set; }
       public Nullable<System.DateTime> ClosedDate { get; set; }
   ```

3. **Add these 3 properties BEFORE the closing brace:**
   ```csharp
       public string RejectionReason { get; set; }
       public string ApprovedBy { get; set; }
       public Nullable<System.DateTime> ApprovalDate { get; set; }
   ```

4. **Final class should look like:**
   ```csharp
   public partial class Account
   {
       public string AccountID { get; set; }
       public string AccountType { get; set; }
       public string CustomerID { get; set; }
       public string OpenedBy { get; set; }
       public string OpenedByRole { get; set; }
       public System.DateTime OpenDate { get; set; }
       public string Status { get; set; }
       public Nullable<System.DateTime> ClosedDate { get; set; }
       
       // NEW COLUMNS (Added for approval workflow)
       public string RejectionReason { get; set; }
       public string ApprovedBy { get; set; }
       public Nullable<System.DateTime> ApprovalDate { get; set; }
   
       // Navigation properties
       public virtual Customer Customer { get; set; }
       public virtual FixedDepositAccount FixedDepositAccount { get; set; }
       public virtual SavingsAccount SavingsAccount { get; set; }
       public virtual LoanAccount LoanAccount { get; set; }
   }
   ```

5. **Save and Rebuild:**
   - Save file (Ctrl+S)
   - Build ? Rebuild Solution

---

### **Step 3: Enable Approval/Rejection in Repository**

After model is updated, uncomment these lines in `AccountRepository.cs`:

**File:** `DB/AccountRepository.cs`

**Find the `ApproveAccount()` method (~line 240):**

```csharp
public bool ApproveAccount(string accountId, string approvedBy)
{
    try
    {
        using (var context = new Banking_DetailsEntities())
        {
            var account = context.Accounts.Find(accountId);
            if (account == null || account.Status != "PENDING")
            {
                return false;
            }

            account.Status = "OPEN";
            
            // UNCOMMENT THESE LINES:
            account.ApprovedBy = approvedBy;
            account.ApprovalDate = DateTime.Now;
            
            context.SaveChanges();
            return true;
        }
    }
    catch (Exception ex)
    {
        System.Diagnostics.Debug.WriteLine($"ERROR approving account: {ex.Message}");
        return false;
    }
}
```

**Find the `RejectAccount()` method (~line 260):**

```csharp
public bool RejectAccount(string accountId, string rejectedBy, string reason)
{
    try
    {
        using (var context = new Banking_DetailsEntities())
        {
            var account = context.Accounts.Find(accountId);
            if (account == null || account.Status != "PENDING")
            {
                return false;
            }

            account.Status = "REJECTED";
            
            // UNCOMMENT THIS LINE:
            account.RejectionReason = reason;
            
            context.SaveChanges();
            return true;
        }
    }
    catch (Exception ex)
    {
        System.Diagnostics.Debug.WriteLine($"ERROR rejecting account: {ex.Message}");
        return false;
    }
}
```

---

## ?? **Verify Fix Worked:**

### **Test 1: Check Account.cs**

```csharp
// Open: DB/Account.cs
// Should now have these properties:

public string RejectionReason { get; set; }
public string ApprovedBy { get; set; }
public Nullable<System.DateTime> ApprovalDate { get; set; }
```

### **Test 2: Try Creating FD/Loan Application**

1. Run application (F5)
2. Login as Customer
3. Click "Apply for FD"
4. Fill form and submit
5. Should see: "? Application submitted! ? Awaiting manager approval"
6. **No more error!**

---

## ?? **Quick Checklist:**

- [ ] **Step 1:** Run SQL script (if not done)
- [ ] **Step 2:** Update EF model (Designer or Manual)
- [ ] **Step 3:** Rebuild DB project
- [ ] **Step 4:** Rebuild solution
- [ ] **Step 5:** Uncomment ApprovedBy/ApprovalDate/RejectionReason lines
- [ ] **Step 6:** Rebuild again
- [ ] **Step 7:** Test application

---

## ?? **Troubleshooting:**

### **Issue: "Update Model from Database" not showing Account table**

**Solution:**
- Click "Refresh" tab instead of "Add" tab
- Expand "Tables" node
- Check the "Account" checkbox
- Click Finish

### **Issue: Build errors after updating model**

**Solution:**
```
1. Clean Solution (Build ? Clean Solution)
2. Rebuild DB project first
3. Then rebuild entire solution
```

### **Issue: Still getting DbUpdateException**

**Solution:**
- Verify Account.cs has the 3 new properties
- Check that uncommented lines don't have typos
- Restart Visual Studio
- Rebuild solution

---

## ?? **Summary:**

**Problem:** Entity Framework doesn't know about new columns  
**Cause:** Model not synced with database  
**Fix:** Update Model from Database (or manual)  
**Time:** 5 minutes  

**After Fix:**
- ? FD/Loan applications work
- ? Manager can approve/reject
- ? Customer sees pending/active/rejected status
- ? No more DbUpdateException

---

**Status:** ?? **AWAITING YOUR ACTION**  
**Next:** Update EF model ? Rebuild ? Test!

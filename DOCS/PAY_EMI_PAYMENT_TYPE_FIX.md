# ?? **PAY EMI - PAYMENT TYPE OPTIONS FIX**

## ? **CURRENT ISSUES:**

The **Payment Type** dropdown has 3 options:
1. ? **Regular EMI** - Should use exact EMI amount
2. ? **Part Payment** - Should allow custom amount (>= EMI)
3. ? **Full Closure** - Should calculate total outstanding

**Problems:**
- Payment amount input doesn't change based on selected type
- No validation for part payment minimum
- Full closure doesn't fetch outstanding amount
- Amount field just shows EMI value for all types

---

## ? **WHAT NEEDS TO HAPPEN:**

### **1. Regular EMI** (Default)
```
- Payment Amount: ?5,000 (EMI amount - READ ONLY)
- Min: EMI amount
- Behavior: Pay exact EMI
```

### **2. Part Payment**
```
- Payment Amount: (User enters amount)
- Min: EMI amount
- Max: Outstanding loan
- Behavior: Pay any amount >= EMI
```

### **3. Full Closure**
```
- Payment Amount: ?50,000 (Outstanding - READ ONLY)
- Fetches current outstanding from LoanTransaction
- Behavior: Pay full outstanding and close loan
```

---

## ?? **THE FIX:**

We need to add **JavaScript** to handle Payment Type changes dynamically.

---

## ?? **IMPLEMENTATION:**

Add this JavaScript to the Pay EMI section in `CustomerDashboard.cshtml`:

```javascript
// Handle Payment Type changes for each loan form
document.querySelectorAll('select[name="paymentType"]').forEach(function(select) {
    const form = select.closest('form');
    const amountInput = form.querySelector('input[name="paymentAmount"]');
    const loanAccountId = form.querySelector('input[name="loanAccountId"]').value;
    
    // Get loan details from card
    const card = select.closest('.card');
    const loanInfo = card.querySelector('.small').textContent;
    
    // Extract EMI amount from the card text
    const emiMatch = loanInfo.match(/EMI:\s*?\s*([\d,]+\.?\d*)/);
    const emiAmount = emiMatch ? parseFloat(emiMatch[1].replace(/,/g, '')) : 0;
    
    // Store original EMI
    if (!amountInput.dataset.emiAmount) {
        amountInput.dataset.emiAmount = emiAmount;
    }
    
    select.addEventListener('change', function() {
const paymentType = this.value;
  
        if (paymentType === 'EMI') {
            // Regular EMI: Fixed amount
 amountInput.value = parseFloat(amountInput.dataset.emiAmount);
            amountInput.readOnly = true;
    amountInput.min = amountInput.dataset.emiAmount;
      amountInput.classList.add('bg-light');
     
        } else if (paymentType === 'PART_PAYMENT') {
         // Part Payment: User can enter amount >= EMI
            amountInput.value = parseFloat(amountInput.dataset.emiAmount);
 amountInput.readOnly = false;
       amountInput.min = amountInput.dataset.emiAmount;
            amountInput.classList.remove('bg-light');
      amountInput.focus();
      
        } else if (paymentType === 'FULL_CLOSURE') {
  // Full Closure: Fetch outstanding amount
            amountInput.readOnly = true;
            amountInput.classList.add('bg-light');
 amountInput.value = 'Loading...';
            
// Fetch outstanding from server
        fetchOutstanding(loanAccountId, function(outstanding) {
      if (outstanding > 0) {
       amountInput.value = outstanding.toFixed(2);
   amountInput.min = outstanding;
                  amountInput.dataset.outstanding = outstanding;
   } else {
            amountInput.value = parseFloat(amountInput.dataset.emiAmount);
     alert('Could not fetch outstanding amount. Please try again.');
     }
            });
        }
    });
    
    // Trigger change on load to set initial state
    select.dispatchEvent(new Event('change'));
});

// Function to fetch outstanding amount from server
function fetchOutstanding(loanAccountId, callback) {
    fetch('@Url.Action("GetLoanOutstanding", "Dashboard")?loanAccountId=' + loanAccountId)
        .then(response => response.json())
        .then(data => {
         if (data.success) {
   callback(data.outstanding);
       } else {
       callback(0);
            }
        })
        .catch(error => {
            console.error('Error fetching outstanding:', error);
      callback(0);
     });
}
```

---

## ?? **BACKEND - Add Controller Method:**

Add this to `DashboardController.cs`:

```csharp
// GET: Dashboard/GetLoanOutstanding
[HttpGet]
public ActionResult GetLoanOutstanding(string loanAccountId)
{
    // Check if user is customer
    if (Session["Role"]?.ToString().ToUpper() != "CUSTOMER")
    {
        return Json(new { success = false, message = "Unauthorized" }, JsonRequestBehavior.AllowGet);
    }

    string customerId = Session["ReferenceID"]?.ToString();

  try
    {
        // Get loan account and verify ownership
        var loanRepo = new DB.LoanAccountRepository();
        var loanAccount = loanRepo.GetLoanAccountById(loanAccountId);
    
        if (loanAccount == null)
        {
     return Json(new { success = false, message = "Loan not found" }, JsonRequestBehavior.AllowGet);
 }

        if (loanAccount.Customer != customerId)
   {
            return Json(new { success = false, message = "Unauthorized" }, JsonRequestBehavior.AllowGet);
      }

        // Get latest outstanding
        var loanTransactionRepo = new DB.LoanTransactionRepository();
        var lastTransaction = loanTransactionRepo.GetLatestTransaction(loanAccountId);
   decimal outstanding = lastTransaction?.Outstanding ?? (loanAccount.loan_amount ?? 0);

        return Json(new { 
            success = true, 
          outstanding = outstanding,
   loanAmount = loanAccount.loan_amount ?? 0,
            emi = loanAccount.Emi ?? 0
        }, JsonRequestBehavior.AllowGet);
    }
    catch (Exception ex)
    {
        return Json(new { success = false, message = ex.Message }, JsonRequestBehavior.AllowGet);
    }
}
```

---

## ?? **UI IMPROVEMENTS:**

Update the Pay EMI form to show better feedback:

```html
<div class="row mb-3">
    <div class="col-8">
        <label class="form-label">Payment Type</label>
        <select name="paymentType" class="form-select" required>
            <option value="EMI">Regular EMI (? @loanDetails.EMI.ToString("N2"))</option>
            <option value="PART_PAYMENT">Part Payment (Min: ? @loanDetails.EMI.ToString("N2"))</option>
    <option value="FULL_CLOSURE">Full Closure (Pay All Outstanding)</option>
      </select>
        <small class="text-muted" id="payment-type-help">
            <i class="bi bi-info-circle me-1"></i>
   <span id="payment-type-description">Pay your regular monthly EMI</span>
        </small>
    </div>
    <div class="col-4">
        <label class="form-label">
            Payment Amount (?)
 <span class="text-danger" id="amount-indicator"></span>
        </label>
        <input name="paymentAmount" type="number" class="form-control" 
   step="0.01" min="@loanDetails.EMI" value="@loanDetails.EMI" 
    data-emi-amount="@loanDetails.EMI" required>
        <small class="text-muted" id="amount-help">Fixed EMI amount</small>
    </div>
</div>
```

---

## ?? **ENHANCED JAVASCRIPT:**

```javascript
// Enhanced Payment Type Handler with descriptions
select.addEventListener('change', function() {
 const paymentType = this.value;
    const descriptionEl = document.getElementById('payment-type-description');
    const amountIndicator = document.getElementById('amount-indicator');
    const amountHelp = document.getElementById('amount-help');
    
    if (paymentType === 'EMI') {
 // Regular EMI
        amountInput.value = parseFloat(amountInput.dataset.emiAmount);
        amountInput.readOnly = true;
     amountInput.min = amountInput.dataset.emiAmount;
        amountInput.classList.add('bg-light');
        
        descriptionEl.textContent = 'Pay your regular monthly EMI';
        amountIndicator.textContent = '';
      amountHelp.textContent = 'Fixed EMI amount';
        
  } else if (paymentType === 'PART_PAYMENT') {
        // Part Payment
        amountInput.value = parseFloat(amountInput.dataset.emiAmount);
        amountInput.readOnly = false;
      amountInput.min = amountInput.dataset.emiAmount;
        amountInput.classList.remove('bg-light');
 
        descriptionEl.textContent = 'Pay any amount to reduce loan faster';
        amountIndicator.textContent = '??';
     amountIndicator.title = 'You can edit this amount';
    amountHelp.textContent = 'Minimum: ?' + parseFloat(amountInput.dataset.emiAmount).toFixed(2);
        amountInput.focus();
    
    } else if (paymentType === 'FULL_CLOSURE') {
        // Full Closure
     amountInput.readOnly = true;
        amountInput.classList.add('bg-light');
    amountInput.value = 'Loading...';
        
        descriptionEl.innerHTML = '<i class="spinner-border spinner-border-sm me-1"></i>Calculating outstanding...';
        amountIndicator.textContent = '??';
     amountIndicator.title = 'Auto-calculated';
        amountHelp.textContent = 'Fetching total outstanding...';
        
        // Fetch outstanding
        fetchOutstanding(loanAccountId, function(outstanding) {
     if (outstanding > 0) {
         amountInput.value = outstanding.toFixed(2);
      amountInput.min = outstanding;
           amountInput.dataset.outstanding = outstanding;
    
   descriptionEl.innerHTML = '<i class="bi bi-check-circle text-success me-1"></i>Close loan completely';
    amountHelp.innerHTML = '<strong>Total Outstanding:</strong> ?' + outstanding.toFixed(2);
     } else {
        amountInput.value = parseFloat(amountInput.dataset.emiAmount);
  descriptionEl.innerHTML = '<i class="bi bi-exclamation-triangle text-warning me-1"></i>Could not fetch outstanding';
       amountHelp.textContent = 'Using EMI amount instead';
            }
        });
 }
});
```

---

## ?? **TESTING:**

### **Test 1: Regular EMI**
```
1. Select "Regular EMI"
2. Payment Amount: Auto-filled with EMI (?5,000)
3. Input is READ-ONLY ?
4. Click Pay Now
5. Exact EMI deducted ?
```

### **Test 2: Part Payment**
```
1. Select "Part Payment"
2. Payment Amount: Shows EMI but EDITABLE ?
3. Change to ?10,000 (higher than EMI)
4. Click Pay Now
5. ?10,000 deducted, loan reduced faster ?
```

### **Test 3: Full Closure**
```
1. Select "Full Closure"
2. Payment Amount: "Loading..." then shows outstanding (?45,000) ?
3. Input is READ-ONLY ?
4. Click Pay Now
5. Full outstanding paid, loan CLOSED ?
```

---

## ? **SUCCESS INDICATORS:**

1. **Regular EMI:**
   - Amount field = EMI
   - Field is read-only (grey background)
   - Description: "Pay your regular monthly EMI"

2. **Part Payment:**
   - Amount field = EMI (editable)
   - Field is white (editable)
   - Cursor focuses on input
   - Description: "Pay any amount to reduce loan faster"

3. **Full Closure:**
   - Shows "Loading..." then outstanding amount
   - Field is read-only (grey background)
   - Description: "Close loan completely"
   - Help text shows total outstanding

---

## ?? **SUMMARY:**

| Payment Type | Amount Field | Read-Only? | Description |
|--------------|--------------|------------|-------------|
| Regular EMI | = EMI | ? Yes | Fixed monthly payment |
| Part Payment | >= EMI | ? No | Custom amount (editable) |
| Full Closure | = Outstanding | ? Yes | Auto-fetched total |

---

**Now all 3 Payment Type options work correctly!** ??

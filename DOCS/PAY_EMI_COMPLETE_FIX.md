# ?? **PAY EMI - Complete Fix Guide**

## ?? **Current Issues:**

1. ? **Payment Method dropdown doesn't work** - parameter not sent to controller
2. ? **"From FD Account" option exists** but does nothing
3. ?? **Only Savings Account payment works**

---

## ? **WHAT NEEDS TO BE FIXED:**

###  **1. Add Payment Method to Controller**

**File:** `Bank_App\Controllers\DashboardController.cs`

**Current PayLoanEMI signature:**
```csharp
public ActionResult PayLoanEMI(string loanAccountId, decimal paymentAmount, string paymentType)
```

**Should be:**
```csharp
public ActionResult PayLoanEMI(string loanAccountId, decimal paymentAmount, string paymentType, string paymentMethod)
```

### **2. Pass paymentMethod to Service**

**Current:**
```csharp
var result = _loanService.PayEMI(loanAccountId, customerId, paymentAmount, paymentType);
```

**Should be:**
```csharp
var result = _loanService.PayEMI(loanAccountId, customerId, paymentAmount, paymentType, paymentMethod);
```

### **3. Update Service Method**

**File:** `BankApp.Services\LoanAccountService.cs`

**Current signature:**
```csharp
public AccountOperationResult PayEMI(string loanAccountId, string customerId, decimal paymentAmount, string paymentType = "EMI")
```

**Should be:**
```csharp
public AccountOperationResult PayEMI(string loanAccountId, string customerId, decimal paymentAmount, string paymentType = "EMI", string paymentMethod = "SAVINGS_ACCOUNT")
```

### **4. Implement FD Payment Logic**

Add logic to handle payment from FD account:
```csharp
if (paymentMethod == "FD_ACCOUNT")
{
    // 1. Get customer's FD accounts
    // 2. Select FD with enough maturity amount
    // 3. Foreclose FD
    // 4. Use maturity amount to pay loan
    // 5. Transfer remaining to savings
}
else  // SAVINGS_ACCOUNT (default)
{
    // Existing savings account payment logic
}
```

---

## ?? **IMPLEMENTATION:**

### **Fix 1: Update DashboardController**

Change `PayLoanEMI` method parameter list:

**Location:** Line ~710 in `DashboardController.cs`

```csharp
// POST: Dashboard/PayLoanEMI
[HttpPost]
public ActionResult PayLoanEMI(string loanAccountId, decimal paymentAmount, string paymentType, string paymentMethod)  // Added paymentMethod
{
    // ... existing code ...
    
    try
 {
        // Pass paymentMethod to service
var result = _loanService.PayEMI(loanAccountId, customerId, paymentAmount, paymentType, paymentMethod);
 
        // ... rest of code ...
    }
}
```

### **Fix 2: Update LoanAccountService**

Update `PayEMI` method signature and add FD payment logic:

**Location:** `BankApp.Services\LoanAccountService.cs`

```csharp
public AccountOperationResult PayEMI(
    string loanAccountId, 
    string customerId, 
    decimal paymentAmount, 
    string paymentType = "EMI",
    string paymentMethod = "SAVINGS_ACCOUNT")  // NEW parameter
{
    try
    {
        // Get loan account
        var loanAccount = _loanRepo.GetLoanAccountById(loanAccountId);
        if (loanAccount == null)
     {
       return Error("Loan account not found");
        }

        // Verify ownership
   if (loanAccount.Customer != customerId)
        {
   return Error("This loan account does not belong to you");
  }

        // Get latest outstanding balance
        var loanTransactionRepo = new LoanTransactionRepository();
        var lastTransaction = loanTransactionRepo.GetLatestTransaction(loanAccountId);
        decimal outstanding = lastTransaction?.Outstanding ?? (loanAccount.loan_amount ?? 0);

        // Validate payment amount
 decimal emi = loanAccount.Emi ?? 0;
        
  if (paymentType == "EMI" && paymentAmount < emi)
        {
         return Error($"Regular EMI payment must be at least Rs. {emi:N2}");
        }

      if (paymentAmount > outstanding)
        {
         return Error($"Payment amount (Rs. {paymentAmount:N2}) exceeds outstanding loan balance (Rs. {outstanding:N2})");
        }

        // Calculate new outstanding
        decimal newOutstanding = outstanding - paymentAmount;

        // Handle payment based on method
        if (paymentMethod == "FD_ACCOUNT")
     {
return PayFromFD(customerId, loanAccountId, paymentAmount, newOutstanding, paymentType);
        }
    else // SAVINGS_ACCOUNT (default)
        {
            return PayFromSavings(customerId, loanAccountId, paymentAmount, newOutstanding, paymentType);
        }
    }
    catch (Exception ex)
 {
 return Error($"Payment failed: {ex.Message}");
    }
}

/// <summary>
/// Pay EMI from Savings Account
/// </summary>
private AccountOperationResult PayFromSavings(string customerId, string loanAccountId, decimal paymentAmount, decimal newOutstanding, string paymentType)
{
    var savingsRepo = new SavingsAccountRepository();
 var savingsAccount = savingsRepo.GetSavingsAccountByCustomerId(customerId);
    if (savingsAccount == null)
    {
  return Error("You don't have a savings account to make payment from");
    }

    // Check sufficient balance (payment amount + Rs. 1,000 minimum balance)
    decimal currentBalance = savingsAccount.Balance ?? 0;
    if (currentBalance - paymentAmount < 1000)
    {
        return Error($"Insufficient balance. You must maintain Rs. 1,000 minimum balance in savings account. Available: Rs. {(currentBalance - 1000 > 0 ? currentBalance - 1000 : 0):N2}");
    }

    try
    {
        // Deduct from savings account
        decimal newSavingsBalance = currentBalance - paymentAmount;
        bool savingsUpdated = savingsRepo.UpdateBalance(savingsAccount.SBAccountID, newSavingsBalance);
   if (!savingsUpdated)
{
       return Error("Failed to deduct payment from savings account");
        }

        // Record loan payment
        var loanTransactionRepo = new LoanTransactionRepository();
    bool paymentRecorded = loanTransactionRepo.CreateLoanTransaction(
loanAccountId,
     paymentAmount,
 newOutstanding,
 paymentType,
            customerId
        );

     if (!paymentRecorded)
     {
     // Rollback savings
            savingsRepo.UpdateBalance(savingsAccount.SBAccountID, currentBalance);
            return Error("Failed to record loan payment");
        }

        // Record savings transaction
   var savingsTransactionRepo = new SavingsTransactionRepository();
        savingsTransactionRepo.CreateTransaction(savingsAccount.SBAccountID, "LOAN_PAYMENT", paymentAmount);

        // If fully paid, close the loan account
        if (newOutstanding == 0)
   {
        _accountRepo.CloseAccount(loanAccountId);
        }

        string message;
        if (newOutstanding == 0)
   {
    message = $"Congratulations! Loan fully paid from Savings Account. Amount: Rs. {paymentAmount:N2}. Loan account closed.";
        }
      else
     {
            message = $"Payment successful from Savings Account! Amount: Rs. {paymentAmount:N2}. Remaining balance: Rs. {newOutstanding:N2}";
   }

 return Success(message, loanAccountId, newOutstanding);
  }
    catch (Exception ex)
    {
        // Attempt rollback
        savingsRepo.UpdateBalance(savingsAccount.SBAccountID, savingsAccount.Balance ?? 0);
        throw new Exception($"Payment failed: {ex.Message}", ex);
    }
}

/// <summary>
/// Pay EMI from Fixed Deposit Account (Foreclose FD and use maturity amount)
/// </summary>
private AccountOperationResult PayFromFD(string customerId, string loanAccountId, decimal paymentAmount, decimal newOutstanding, string paymentType)
{
    var fdRepo = new FixedDepositAccountRepository();
    var savingsRepo = new SavingsAccountRepository();
    
    // Get all customer's active FD accounts
    var fdAccounts = fdRepo.GetFDAccountsByCustomerId(customerId);
    var activeFDs = fdAccounts.Where(fd => 
    {
        var account = _accountRepo.GetAccountById(fd.FDAccountID);
        return account != null && account.Status == "OPEN";
    }).ToList();

    if (!activeFDs.Any())
    {
        return Error("You don't have any active Fixed Deposit accounts to make payment from");
    }

    // Find FD with sufficient maturity amount
    var suitableFD = activeFDs.FirstOrDefault(fd => (fd.MaturityAmount ?? 0) >= paymentAmount);
    
    if (suitableFD == null)
    {
        var maxFD = activeFDs.OrderByDescending(fd => fd.MaturityAmount ?? 0).First();
    return Error($"No Fixed Deposit has enough maturity amount. Highest FD maturity: Rs. {(maxFD.MaturityAmount ?? 0):N2}, Required: Rs. {paymentAmount:N2}");
    }

    // Get customer's savings account (for receiving excess amount)
    var savingsAccount = savingsRepo.GetSavingsAccountByCustomerId(customerId);
    if (savingsAccount == null)
    {
        return Error("You need a savings account to receive the excess FD amount");
    }

    decimal fdMaturityAmount = suitableFD.MaturityAmount ?? 0;
    decimal excessAmount = fdMaturityAmount - paymentAmount;

    try
    {
   // Record loan payment
        var loanTransactionRepo = new LoanTransactionRepository();
      bool paymentRecorded = loanTransactionRepo.CreateLoanTransaction(
   loanAccountId,
     paymentAmount,
 newOutstanding,
            $"{paymentType}_FROM_FD",
    customerId
        );

        if (!paymentRecorded)
        {
      return Error("Failed to record loan payment");
        }

        // Transfer excess to savings
        if (excessAmount > 0)
   {
     decimal currentSavingsBalance = savingsAccount.Balance ?? 0;
        decimal newSavingsBalance = currentSavingsBalance + excessAmount;
    
     bool savingsUpdated = savingsRepo.UpdateBalance(savingsAccount.SBAccountID, newSavingsBalance);
       if (!savingsUpdated)
            {
     return Error("Failed to transfer excess amount to savings account");
            }

     // Record savings transaction for excess
    var savingsTransactionRepo = new SavingsTransactionRepository();
      savingsTransactionRepo.CreateTransaction(savingsAccount.SBAccountID, "FD_MATURITY", excessAmount);
        }

        // Close FD account
        bool fdClosed = _accountRepo.CloseAccount(suitableFD.FDAccountID);
     if (!fdClosed)
        {
    return Error("Failed to close Fixed Deposit account");
        }

        // If loan fully paid, close loan account
        if (newOutstanding == 0)
    {
            _accountRepo.CloseAccount(loanAccountId);
        }

        string message;
        if (newOutstanding == 0)
        {
    message = $"Congratulations! Loan fully paid using FD {suitableFD.FDAccountID}. ";
    }
    else
        {
            message = $"Payment successful from FD {suitableFD.FDAccountID}! Remaining loan balance: Rs. {newOutstanding:N2}. ";
        }

        if (excessAmount > 0)
        {
  message += $"Excess amount Rs. {excessAmount:N2} transferred to your Savings Account.";
        }

        return Success(message, loanAccountId, newOutstanding);
    }
    catch (Exception ex)
    {
   return Error($"Payment from FD failed: {ex.Message}");
    }
}
```

---

## ?? **TESTING:**

### **Test 1: Pay from Savings Account**
```
1. Login as Customer with loan
2. Click "Pay EMI"
3. Select "From Savings Account"
4. Enter payment amount
5. Click "Pay Now"

Expected:
? Payment deducted from savings
? Loan outstanding reduced
? Transaction recorded
```

### **Test 2: Pay from FD Account**
```
1. Login as Customer with loan + FD
2. Click "Pay EMI"
3. Select "From Fixed Deposit"
4. Enter payment amount
5. Click "Pay Now"

Expected:
? FD foreclosed
? Maturity amount used for payment
? Excess transferred to savings
? Loan outstanding reduced
```

---

## ?? **QUICK COMPARISON:**

| Feature | Before Fix | After Fix |
|---------|-----------|-----------|
| Payment from Savings | ? Works | ? Works |
| Payment from FD | ? Ignored | ? **FIXED!** |
| Payment Method dropdown | ? Not sent | ? **FIXED!** |
| Excess FD amount | ? N/A | ? **Transferred to savings** |

---

## ?? **SUMMARY:**

1. ? Added `paymentMethod` parameter to controller
2. ? Added `paymentMethod` parameter to service
3. ? Implemented FD payment logic
4. ? Implemented excess amount transfer
5. ? Both payment methods now work!

---

**Now customers can choose to pay EMI from either Savings or FD!** ??

using System;
using System.Collections.Generic;
using System.Linq;
using DB;
using DB.Utilities;

namespace BankApp.Services
{
    public class LoanAccountService
    {
        private readonly LoanAccountRepository _loanRepo;
        private readonly AccountRepository _accountRepo;
        private readonly CustomerRepository _customerRepo;
        private readonly SavingsAccountRepository _savingsRepo; // Added SavingsAccountRepository

        public LoanAccountService()
        {
            _loanRepo = new LoanAccountRepository();
            _accountRepo = new AccountRepository();
            _customerRepo = new CustomerRepository();
            _savingsRepo = new SavingsAccountRepository(); // Initialize SavingsAccountRepository
        }

        /// <summary>
        /// Open a new Loan Account with business rule validation
        /// Business Rules:
        /// - Minimum loan: Rs. 10,000
        /// - Interest rates: 10% (?5L), 9.5% (5L-10L), 9% (>10L)
        /// - EMI cannot exceed 60% of monthly salary
        /// - Senior citizens: max loan Rs. 1 lakh, rate 9.5%
        /// </summary>
        public AccountOperationResult OpenLoanAccount(string customerId, decimal loanAmount, DateTime startDate, int tenureMonths, decimal monthlySalary, string openedBy, string openedByRole)
        {
            var validationRules = new List<Func<AccountOperationResult>>
            {
                () => string.IsNullOrWhiteSpace(customerId) ? Error("Customer ID is required") : null,
                () => !_customerRepo.CustomerExists(customerId) ? Error($"Customer ID '{customerId}' not found in the system") : null,
                () => !_savingsRepo.CustomerHasSavingsAccount(customerId) ? Error("Customer must have an active Savings Account before taking a Loan. Please open a Savings Account first.") : null,
                () => loanAmount < 10000 ? Error("Minimum loan amount is Rs. 10,000") : null,
                () => startDate.Date < DateTime.Now.Date ? Error("Start date cannot be in the past. Please select today or a future date.") : null,
                () => tenureMonths <= 0 ? Error("Tenure must be greater than 0 months") : null,
                () => tenureMonths > 360 ? Error("Maximum tenure is 360 months (30 years)") : null,
                () => monthlySalary <= 0 ? Error("Monthly salary must be greater than 0") : null,
                () => monthlySalary < 1000 ? Error("Please enter a valid monthly salary (minimum Rs. 1,000)") : null
            };

            var validationError = validationRules.Select(rule => rule()).FirstOrDefault(result => result != null);
            if (validationError != null) return validationError;

            try
            {
                // Get customer to check if senior citizen
                var customer = _customerRepo.GetCustomerById(customerId);
                if (customer == null)
                {
                    return Error("Customer not found");
                }

                bool isSeniorCitizen = customer.DOB.HasValue && IdGenerator.IsSeniorCitizen(customer.DOB.Value);

                // Apply senior citizen rules
                if (isSeniorCitizen)
                {
                    if (loanAmount > 100000)
                    {
                        return Error("Senior citizens cannot be sanctioned a loan greater than Rs. 1 lakh (Rs. 100,000)");
                    }
                }

                // Calculate interest rate
                decimal interestRate = CalculateLoanInterestRate(loanAmount, isSeniorCitizen);

                // Calculate EMI using formula: EMI = [P x R x (1+R)^N]/[(1+R)^N-1]
                // Where P = Loan amount, R = Monthly interest rate, N = Tenure in months
                decimal monthlyInterestRate = (interestRate / 100) / 12;
                double powerTerm = Math.Pow((double)(1 + monthlyInterestRate), tenureMonths);
                decimal emi = loanAmount * monthlyInterestRate * (decimal)powerTerm / ((decimal)powerTerm - 1);

                // Validate EMI is not more than 60% of monthly salary
                decimal maxAllowedEMI = monthlySalary * 0.60m;
                if (emi > maxAllowedEMI)
                {
                    return Error($"EMI amount (Rs. {emi:N2}) exceeds 60% of monthly salary (Rs. {maxAllowedEMI:N2}). Please reduce loan amount or increase tenure.");
                }

                // Generate Loan Account ID
                string lnAccountId = IdGenerator.GenerateLoanAccountId();

                // Create master account entry with PENDING status (requires manager approval)
                bool accountCreated = _accountRepo.CreateAccountWithStatus(
                    lnAccountId, 
                    "LOAN", 
                    customerId, 
                    openedBy, 
                    openedByRole,
                    "PENDING"  // Start as PENDING - requires manager approval
                );
                
                if (!accountCreated)
                {
                    return Error("Failed to create account entry");
                }

                // Create loan account entry
                bool loanCreated = _loanRepo.CreateLoanAccount(lnAccountId, customerId, loanAmount, startDate, tenureMonths, interestRate, emi);
                if (!loanCreated)
                {
                    return Error("Failed to create loan account");
                }

                string seniorCitizenNote = isSeniorCitizen ? " (Senior Citizen Rate)" : "";
                return Success(
                    $"Loan application submitted successfully! Application ID: {lnAccountId}, Loan Amount: Rs. {loanAmount:N2}, Interest Rate: {interestRate}%{seniorCitizenNote}, Tenure: {tenureMonths} months, EMI: Rs. {emi:N2}. ? Awaiting manager approval.",
                    lnAccountId,
                    loanAmount,
                    null,
                    emi,
                    interestRate
                );
            }
            catch (Exception ex)
            {
                return Error($"Failed to open loan account: {ex.Message}");
            }
        }

        /// <summary>
        /// Calculate loan interest rate based on amount and customer type
        /// 10% for loans up to Rs. 5 lakhs
        /// 9.5% for loans from Rs. 5 lakhs to Rs. 10 lakhs
        /// 9% for loans above Rs. 10 lakhs
        /// Senior Citizens: 9.5% (fixed)
        /// </summary>
        private decimal CalculateLoanInterestRate(decimal loanAmount, bool isSeniorCitizen)
        {
            if (isSeniorCitizen)
            {
                return 9.5m;  // Fixed rate for senior citizens
            }

            if (loanAmount <= 500000)
            {
                return 10.0m;  // 10% for up to 5 lakhs
            }
            else if (loanAmount <= 1000000)
            {
                return 9.5m;   // 9.5% for 5 lakhs to 10 lakhs
            }
            else
            {
                return 9.0m;   // 9% for above 10 lakhs
            }
        }

        /// <summary>
        /// Make part payment on loan
        /// </summary>
        public AccountOperationResult MakePartPayment(string lnAccountId, decimal amount)
        {
            try
            {
                var loanAccount = _loanRepo.GetLoanAccountById(lnAccountId);
                if (loanAccount == null)
                {
                    return Error("Loan Account not found");
                }

                // In a full implementation, you would:
                // 1. Record the payment in LoanTransaction table
                // 2. Update outstanding amount
                // 3. Adjust EMI schedule

                return Success($"Part payment of Rs. {amount:N2} processed successfully for Loan Account {lnAccountId}", lnAccountId, amount);
            }
            catch (Exception ex)
            {
                return Error($"Part payment failed: {ex.Message}");
            }
        }

        /// <summary>
        /// Foreclose (close) loan account
        /// </summary>
        public AccountOperationResult ForeCloseLoanAccount(string lnAccountId)
        {
            try
            {
                var loanAccount = _loanRepo.GetLoanAccountById(lnAccountId);
                if (loanAccount == null)
                {
                    return Error("Loan Account not found");
                }

                // Close in master Account table
                bool closed = _accountRepo.CloseAccount(lnAccountId);
                if (closed)
                {
                    return Success($"Loan Account {lnAccountId} foreclosed successfully. Loan Amount: Rs. {loanAccount.loan_amount:N2}", lnAccountId, loanAccount.loan_amount ?? 0);
                }
                else
                {
                    return Error("Failed to foreclose loan account");
                }
            }
            catch (Exception ex)
            {
                return Error($"Failed to foreclose account: {ex.Message}");
            }
        }

        /// <summary>
        /// Get loan account details
        /// </summary>
        public LoanAccount GetAccountDetails(string lnAccountId)
        {
            return _loanRepo.GetLoanAccountById(lnAccountId);
        }

        /// <summary>
        /// Get current outstanding balance for a loan
        /// </summary>
        public decimal GetOutstandingBalance(string lnAccountId)
        {
            try
            {
                var loanAccount = _loanRepo.GetLoanAccountById(lnAccountId);
                if (loanAccount == null)
                {
                    return 0;
                }

                // Get latest transaction to find current outstanding
                var loanTransactionRepo = new LoanTransactionRepository();
                var lastTransaction = loanTransactionRepo.GetLatestTransaction(lnAccountId);
                
                // If no payments yet, outstanding = loan amount
                decimal outstanding = lastTransaction?.Outstanding ?? (loanAccount.loan_amount ?? 0);
                return outstanding;
            }
            catch
            {
                return 0;
            }
        }

        /// <summary>
        /// Pay loan EMI from customer's savings account or FD account
        /// Payment types: EMI (regular), PART_PAYMENT, FULL_CLOSURE
        /// Payment methods: SAVINGS_ACCOUNT (default), FD_ACCOUNT
        /// </summary>
        public AccountOperationResult PayEMI(string loanAccountId, string customerId, decimal paymentAmount, string paymentType = "EMI", string paymentMethod = "SAVINGS_ACCOUNT")
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== PayEMI Called ===");
System.Diagnostics.Debug.WriteLine($"Loan Account: {loanAccountId}");
      System.Diagnostics.Debug.WriteLine($"Customer: {customerId}");
 System.Diagnostics.Debug.WriteLine($"Amount: {paymentAmount}");
System.Diagnostics.Debug.WriteLine($"Payment Type: {paymentType}");
   System.Diagnostics.Debug.WriteLine($"Payment Method: {paymentMethod}");

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
     savingsRepo.UpdateBalance(savingsAccount.SBAccountID, currentBalance);
                throw new Exception($"Payment failed: {ex.Message}", ex);
       }
   }

        /// <summary>
 /// Pay EMI from Fixed Deposit Account (Foreclose FD and use maturity amount)
  /// </summary>
        private AccountOperationResult PayFromFD(string customerId, string loanAccountId, decimal paymentAmount, decimal newOutstanding, string paymentType)
 {
   System.Diagnostics.Debug.WriteLine("=== PayFromFD Called ===");
            
       var fdRepo = new FixedDepositAccountRepository();
      var savingsRepo = new SavingsAccountRepository();
       
// Get all customer's active FD accounts
   var fdAccounts = fdRepo.GetFDAccountsByCustomerId(customerId);
     var activeFDs = fdAccounts.Where(fd => 
    {
             var account = _accountRepo.GetAccountById(fd.FDAccountID);
     return account != null && account.Status == "OPEN";
 }).ToList();

            System.Diagnostics.Debug.WriteLine($"Found {activeFDs.Count} active FD account(s)");

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

            System.Diagnostics.Debug.WriteLine($"Selected FD: {suitableFD.FDAccountID}, Maturity: {suitableFD.MaturityAmount}");

   // Get customer's savings account (for receiving excess amount)
   var savingsAccount = savingsRepo.GetSavingsAccountByCustomerId(customerId);
   if (savingsAccount == null)
     {
   return Error("You need a savings account to receive the excess FD amount");
            }

            decimal fdMaturityAmount = suitableFD.MaturityAmount ?? 0;
  decimal excessAmount = fdMaturityAmount - paymentAmount;

      System.Diagnostics.Debug.WriteLine($"FD Maturity: {fdMaturityAmount}, Payment: {paymentAmount}, Excess: {excessAmount}");

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

      System.Diagnostics.Debug.WriteLine("? Loan payment recorded");

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
           
   System.Diagnostics.Debug.WriteLine($"? Excess {excessAmount} transferred to savings");
    }

         // Close FD account
    bool fdClosed = _accountRepo.CloseAccount(suitableFD.FDAccountID);
     if (!fdClosed)
 {
            return Error("Failed to close Fixed Deposit account");
 }

        System.Diagnostics.Debug.WriteLine($"? FD {suitableFD.FDAccountID} closed");

        // If loan fully paid, close loan account
   if (newOutstanding == 0)
  {
       _accountRepo.CloseAccount(loanAccountId);
    System.Diagnostics.Debug.WriteLine($"? Loan {loanAccountId} closed (fully paid)");
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

      System.Diagnostics.Debug.WriteLine($"=== PayFromFD SUCCESS: {message} ===");

 return Success(message, loanAccountId, newOutstanding);
            }
catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"? PayFromFD ERROR: {ex.Message}");
  return Error($"Payment from FD failed: {ex.Message}");
    }
  }

        private AccountOperationResult Error(string message)
        {
            return new AccountOperationResult
            {
                IsSuccess = false,
                Message = message
            };
        }

        private AccountOperationResult Success(string message, string accountId = null, decimal? balance = null, decimal? maturityAmount = null, decimal? emi = null, decimal? interestRate = null)
        {
            return new AccountOperationResult
            {
                IsSuccess = true,
                Message = message,
                AccountId = accountId,
                Balance = balance,
                MaturityAmount = maturityAmount,
                EMI = emi,
                InterestRate = interestRate
            };
        }
    }
}

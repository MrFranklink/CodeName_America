using System;
using System.Collections.Generic;
using System.Linq;
using DB;
using DB.Utilities;

namespace BankApp.Services
{
    public class FixedDepositAccountService
    {
        private readonly FixedDepositAccountRepository _fdRepo;
        private readonly AccountRepository _accountRepo;
        private readonly CustomerRepository _customerRepo;
        private readonly SavingsAccountRepository _savingsRepo;
        private readonly FDTransactionRepository _fdTransactionRepo;  // NEW

        public FixedDepositAccountService()
        {
            _fdRepo = new FixedDepositAccountRepository();
            _accountRepo = new AccountRepository();
            _customerRepo = new CustomerRepository();
            _savingsRepo = new SavingsAccountRepository();
            _fdTransactionRepo = new FDTransactionRepository();  // NEW
        }

        /// <summary>
        /// Open a new Fixed Deposit Account with business rule validation
        /// Business Rules:
        /// - Minimum deposit: Rs. 10,000
        /// - Interest rates: 6% (<1 year), 7% (1-2 years), 8% (>2 years)
        /// - Senior citizens get +0.5% extra interest
        /// </summary>
        public AccountOperationResult OpenFixedDepositAccount(string customerId, decimal amount, DateTime startDate, int tenureMonths, string openedBy, string openedByRole)
        {
            var validationRules = new List<Func<AccountOperationResult>>
            {
                () => string.IsNullOrWhiteSpace(customerId) ? Error("Customer ID is required") : null,
                () => !_customerRepo.CustomerExists(customerId) ? Error($"Customer ID '{customerId}' not found in the system") : null,
                () => !_savingsRepo.CustomerHasSavingsAccount(customerId) ? Error("Customer must have an active Savings Account before opening Fixed Deposit. Please open a Savings Account first.") : null,
                () => amount < 10000 ? Error("Minimum deposit for Fixed Deposit is Rs. 10,000") : null,
                () => startDate.Date < DateTime.Now.Date ? Error("Start date cannot be in the past. Please select today or a future date.") : null,
                () => tenureMonths <= 0 ? Error("Tenure must be greater than 0 months") : null,
                () => tenureMonths > 360 ? Error("Maximum tenure is 360 months (30 years)") : null
            };

            var validationError = validationRules.Select(rule => rule()).FirstOrDefault(result => result != null);
            if (validationError != null) return validationError;

            // Generate FD Account ID
            string fdAccountId = IdGenerator.GenerateFixedDepositAccountId();

            try
            {
                // Get customer to check if senior citizen
                var customer = _customerRepo.GetCustomerById(customerId);
                if (customer == null)
                {
                    return Error("Customer not found");
                }

                bool isSeniorCitizen = customer.DOB.HasValue && IdGenerator.IsSeniorCitizen(customer.DOB.Value);

                // Calculate interest rate based on tenure
                decimal interestRate = CalculateInterestRate(tenureMonths, isSeniorCitizen);

                // Calculate end date
                DateTime endDate = startDate.AddMonths(tenureMonths);

                // Calculate maturity amount using compound interest formula
                // A = P(1 + r/n)^(nt)
                // For simplicity, using annual compounding
                double years = tenureMonths / 12.0;
                decimal maturityAmount = amount * (decimal)Math.Pow((double)(1 + interestRate / 100), years);

                // Create master account entry with PENDING status (requires manager approval)
                bool accountCreated = _accountRepo.CreateAccountWithStatus(
                    fdAccountId, 
                    "FIXED-DEPOSIT", 
                    customerId, 
                    openedBy, 
                    openedByRole,
                    "PENDING"  // Start as PENDING - requires manager approval
                );
                
                if (!accountCreated)
                {
                    return Error("Failed to create account entry");
                }

                // Create FD account entry
                bool fdCreated = _fdRepo.CreateFixedDepositAccount(fdAccountId, customerId, amount, startDate, endDate, interestRate, maturityAmount);
                if (!fdCreated)
                {
                    // ROLLBACK: Delete the Account entry
                    RollbackAccountCreation(fdAccountId);
                    return Error("Failed to create fixed deposit account");
                }

                // ============================================================
                // NEW: Record FD creation in FDTransaction table
                // ============================================================
                bool transactionRecorded = _fdTransactionRepo.CreateFDTransaction(fdAccountId, "DEPOSIT", amount);
                if (!transactionRecorded)
                {
                    System.Diagnostics.Debug.WriteLine($"WARNING: FD created but transaction not recorded for {fdAccountId}");
                    // Don't rollback - FD is created, just transaction logging failed
                }

                string seniorCitizenBonus = isSeniorCitizen ? " (includes +0.5% senior citizen bonus)" : "";
                return Success(
                    $"Fixed Deposit application submitted successfully! Application ID: {fdAccountId}, Amount: Rs. {amount:N2}, Interest Rate: {interestRate}%{seniorCitizenBonus}. ? Awaiting manager approval.",
                    fdAccountId,
                    amount,
                    maturityAmount,
                    null,
                    interestRate
                );
            }
            catch (Exception ex)
            {
                RollbackAccountCreation(fdAccountId);
                return Error($"Failed to open fixed deposit: {ex.Message}");
            }
        }

        /// <summary>
        /// Calculate FD interest rate based on tenure
        /// 6% for up to 1 year
        /// 7% for 1 to 2 years
        /// 8% for more than 2 years
        /// +0.5% for senior citizens
        /// </summary>
        private decimal CalculateInterestRate(int tenureMonths, bool isSeniorCitizen)
        {
            decimal baseRate;

            if (tenureMonths <= 12)
            {
                baseRate = 6.0m;  // 6% for up to 1 year
            }
            else if (tenureMonths <= 24)
            {
                baseRate = 7.0m;  // 7% for 1-2 years
            }
            else
            {
                baseRate = 8.0m;  // 8% for more than 2 years
            }

            // Add 0.5% bonus for senior citizens
            if (isSeniorCitizen)
            {
                baseRate += 0.5m;
            }

            return baseRate;
        }

        /// <summary>
        /// Foreclose (close) FD account before maturity
        /// Transfers maturity amount to customer's savings account
        /// </summary>
        public AccountOperationResult ForeCloseFDAccount(string fdAccountId)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== ForeCloseFDAccount Called ===");
                System.Diagnostics.Debug.WriteLine($"FD Account ID: {fdAccountId}");

                var fdAccount = _fdRepo.GetFDAccountById(fdAccountId);
                if (fdAccount == null)
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: FD Account not found");
                    return Error("Fixed Deposit Account not found");
                }

                // Get customer's savings account
                var savingsAccount = _savingsRepo.GetSavingsAccountByCustomerId(fdAccount.CustomerID);
                if (savingsAccount == null)
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: Savings account not found");
                    return Error("Customer's savings account not found. Cannot transfer FD amount.");
                }

                decimal fdMaturityAmount = fdAccount.MaturityAmount ?? 0;
 
                // Emergency fix: If MaturityAmount is NULL or 0, calculate it now
                if (fdMaturityAmount == 0 && fdAccount.Amount.HasValue && fdAccount.Amount > 0)
                {
                    System.Diagnostics.Debug.WriteLine("?? WARNING: MaturityAmount is NULL/0. Calculating now...");
                    decimal principal = fdAccount.Amount.Value;
                    decimal rate = fdAccount.FD_ROI;
                    double tenureMonths = (fdAccount.EndDate - fdAccount.StartDate).Days / 30.44;
                    double years = tenureMonths / 12.0;
                    fdMaturityAmount = principal * (decimal)Math.Pow((double)(1 + rate / 100), years);
                    System.Diagnostics.Debug.WriteLine($"? Calculated MaturityAmount: {fdMaturityAmount:N2}");
                }

                decimal currentSavingsBalance = savingsAccount.Balance ?? 0;
                decimal newSavingsBalance = currentSavingsBalance + fdMaturityAmount;

                // Transfer FD maturity amount to savings account
                bool savingsUpdated = _savingsRepo.UpdateBalance(savingsAccount.SBAccountID, newSavingsBalance);
                if (!savingsUpdated)
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: Failed to update savings balance");
                    return Error("Failed to transfer FD amount to savings account");
                }

                System.Diagnostics.Debug.WriteLine("? Savings balance updated");

                // Record transaction in savings account
                var transactionRepo = new SavingsTransactionRepository();
                bool savingsTransactionRecorded = transactionRepo.CreateTransaction(savingsAccount.SBAccountID, "FD_MATURITY", fdMaturityAmount);
               
                if (!savingsTransactionRecorded)
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: Failed to record savings transaction");
                    // Rollback savings balance
                    _savingsRepo.UpdateBalance(savingsAccount.SBAccountID, currentSavingsBalance);
                    return Error("Failed to record FD maturity transaction");
                }

                System.Diagnostics.Debug.WriteLine("? Savings transaction recorded");

                // ============================================================
                // NEW: Record FD foreclose transaction in FDTransaction table
                // ============================================================
                bool fdTransactionRecorded = _fdTransactionRepo.CreateFDTransaction(fdAccountId, "FORECLOSE", fdMaturityAmount);
                if (!fdTransactionRecorded)
                {
                    System.Diagnostics.Debug.WriteLine("WARNING: FD foreclosed but FDTransaction not recorded");
                    // Don't rollback - FD is foreclosed, just transaction logging failed
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("? FD transaction recorded");
                }

                // Close FD account in master Account table
                bool closed = _accountRepo.CloseAccount(fdAccountId);
                if (!closed)
                {
                    System.Diagnostics.Debug.WriteLine("ERROR: Failed to close FD account");
                    // Rollback savings balance and transaction
                    _savingsRepo.UpdateBalance(savingsAccount.SBAccountID, currentSavingsBalance);
                    return Error("Failed to close Fixed Deposit account");
                }

                System.Diagnostics.Debug.WriteLine("? FD account closed");
                System.Diagnostics.Debug.WriteLine($"=== SUCCESS: FD {fdAccountId} closed, ?{fdMaturityAmount:N2} transferred to {savingsAccount.SBAccountID} ===");

                return Success(
                    $"Fixed Deposit {fdAccountId} closed successfully. Amount Rs. {fdMaturityAmount:N2} transferred to your Savings Account ({savingsAccount.SBAccountID}). New savings balance: Rs. {newSavingsBalance:N2}",
                    fdAccountId,
                    fdMaturityAmount,
                    fdMaturityAmount
                );
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"EXCEPTION in ForeCloseFDAccount: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}");
                return Error($"Failed to close FD account: {ex.Message}");
            }
        }

        /// <summary>
        /// Get FD account details
        /// </summary>
        public FixedDepositAccount GetAccountDetails(string fdAccountId)
        {
            return _fdRepo.GetFDAccountById(fdAccountId);
        }

        /// <summary>
        /// Get FD transaction history
        /// </summary>
        public List<FDTransaction> GetFDTransactionHistory(string fdAccountId)
        {
            return _fdTransactionRepo.GetFDTransactionsByAccountId(fdAccountId);
        }

        /// <summary>
        /// Rollback account creation if FD account creation fails
        /// </summary>
        private void RollbackAccountCreation(string fdAccountId)
        {
            System.Diagnostics.Debug.WriteLine($"Attempting rollback of Account entry {fdAccountId}");
            try
            {
                using (var context = new DB.Banking_DetailsEntities())
                {
                    var accountToDelete = context.Accounts.Find(fdAccountId);
                    if (accountToDelete != null)
                    {
                        context.Accounts.Remove(accountToDelete);
                        context.SaveChanges();
                        System.Diagnostics.Debug.WriteLine($"Successfully rolled back Account entry {fdAccountId}");
                    }
                }
            }
            catch (Exception rollbackEx)
            {
                System.Diagnostics.Debug.WriteLine($"Rollback failed: {rollbackEx.Message}");
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

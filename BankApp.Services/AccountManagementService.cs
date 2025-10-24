using System;
using System.Collections.Generic;
using DB;

namespace BankApp.Services
{
    /// <summary>
    /// Service for account management operations
    /// </summary>
    public class AccountManagementService
    {
        private readonly AccountRepository _accountRepo;
        private readonly CustomerRepository _customerRepo;
        private readonly SavingsAccountRepository _savingsRepo;
        private readonly FixedDepositAccountRepository _fdRepo;
        private readonly LoanAccountRepository _loanRepo;

        public AccountManagementService()
        {
            _accountRepo = new AccountRepository();
            _customerRepo = new CustomerRepository();
            _savingsRepo = new SavingsAccountRepository();
            _fdRepo = new FixedDepositAccountRepository();
            _loanRepo = new LoanAccountRepository();
        }

        /// <summary>
        /// Get all accounts
        /// </summary>
        public List<AccountDTO> GetAllAccounts()
        {
            var accounts = _accountRepo.GetAllAccounts();
            var accountDTOs = new List<AccountDTO>();

            foreach (var account in accounts)
            {
                accountDTOs.Add(new AccountDTO
                {
                    AccountID = account.AccountID,
                    AccountType = account.AccountType,
                    CustomerID = account.CustomerID,
                    OpenedBy = account.OpenedBy,
                    OpenedByRole = account.OpenedByRole,
                    OpenDate = account.OpenDate,
                    Status = account.Status,
                    ClosedDate = account.ClosedDate,
                    RejectionReason = account.RejectionReason  // Add rejection reason
                });
            }

            return accountDTOs;
        }

        /// <summary>
        /// Get total account count
        /// </summary>
        public int GetTotalAccountCount()
        {
            return _accountRepo.GetTotalAccountCount();
        }

        /// <summary>
        /// Get accounts by customer ID
        /// </summary>
        public List<AccountDTO> GetAccountsByCustomerId(string customerId)
        {
            var accounts = _accountRepo.GetAccountsByCustomerId(customerId);
            var accountDTOs = new List<AccountDTO>();

            foreach (var account in accounts)
            {
                accountDTOs.Add(new AccountDTO
                {
                    AccountID = account.AccountID,
                    AccountType = account.AccountType,
                    CustomerID = account.CustomerID,
                    OpenedBy = account.OpenedBy,
                    OpenedByRole = account.OpenedByRole,
                    OpenDate = account.OpenDate,
                    Status = account.Status,
                    ClosedDate = account.ClosedDate,
                    RejectionReason = account.RejectionReason  // Add rejection reason
                });
            }

            return accountDTOs;
        }

        /// <summary>
        /// Get account by ID
        /// </summary>
        public AccountDTO GetAccountById(string accountId)
        {
            var account = _accountRepo.GetAccountById(accountId);
            if (account == null)
            {
                return null;
            }

            return new AccountDTO
            {
                AccountID = account.AccountID,
                AccountType = account.AccountType,
                CustomerID = account.CustomerID,
                OpenedBy = account.OpenedBy,
                OpenedByRole = account.OpenedByRole,
                OpenDate = account.OpenDate,
                Status = account.Status,
                ClosedDate = account.ClosedDate,
                RejectionReason = account.RejectionReason  // Add rejection reason
            };
        }

        /// <summary>
        /// Get customer profile by customer ID
        /// </summary>
        public CustomerProfileDTO GetCustomerProfile(string customerId)
        {
            var customer = _customerRepo.GetCustomerById(customerId);
            if (customer == null)
            {
                return null;
            }

            return new CustomerProfileDTO
            {
                Custid = customer.Custid,
                Custname = customer.Custname,
                DOB = customer.DOB,
                Pan = customer.Pan,
                Address = customer.Address,
                PhoneNumber = customer.PhoneNumber
            };
        }

        /// <summary>
        /// Get savings account balance
        /// </summary>
        public decimal GetSavingsBalance(string accountId)
        {
            var savingsAccount = _savingsRepo.GetSavingsAccountById(accountId);
            return savingsAccount?.Balance ?? 0;
        }

        /// <summary>
        /// Get account details with balance/amount based on account type
        /// </summary>
        public AccountDetailsDTO GetAccountDetails(string accountId, string accountType)
        {
            var accountDetailsDTO = new AccountDetailsDTO
            {
                AccountID = accountId,
                AccountType = accountType
            };

            if (accountType == "SAVING")
            {
                var savingsAccount = _savingsRepo.GetSavingsAccountById(accountId);
                if (savingsAccount != null)
                {
                    accountDetailsDTO.Balance = savingsAccount.Balance ?? 0;
                }
            }
            else if (accountType == "FIXED-DEPOSIT")
            {
                var fdAccount = _fdRepo.GetFDAccountById(accountId);
                if (fdAccount != null)
                {
                    accountDetailsDTO.Amount = fdAccount.Amount ?? 0;
                    accountDetailsDTO.MaturityAmount = fdAccount.MaturityAmount ?? 0;
                    accountDetailsDTO.InterestRate = fdAccount.FD_ROI;
                    accountDetailsDTO.StartDate = fdAccount.StartDate;
                    accountDetailsDTO.EndDate = fdAccount.EndDate;
                }
            }
            else if (accountType == "LOAN")
            {
                var loanAccount = _loanRepo.GetLoanAccountById(accountId);
                if (loanAccount != null)
                {
                    accountDetailsDTO.LoanAmount = loanAccount.loan_amount ?? 0;
                    accountDetailsDTO.EMI = loanAccount.Emi ?? 0;
                    accountDetailsDTO.InterestRate = loanAccount.Ln_roi;
                    accountDetailsDTO.Tenure = loanAccount.Tenure;
                    accountDetailsDTO.StartDate = loanAccount.Start_date;
                }
            }

            return accountDetailsDTO;
        }

        /// <summary>
        /// Approve a pending account (Manager only)
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
                    return Error($"Cannot approve account with status: {account.Status}. Only PENDING accounts can be approved.");
                }
                
                bool approved = _accountRepo.ApproveAccount(accountId, approvedBy);
                
                if (approved)
                {
                    string accountTypeName = account.AccountType == "FIXED-DEPOSIT" ? "Fixed Deposit" : 
                                            account.AccountType == "LOAN" ? "Loan" : account.AccountType;
                    return Success($"{accountTypeName} account {accountId} approved successfully! Customer can now use this account.");
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
        /// Reject a pending account (Manager only)
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
                    return Error($"Cannot reject account with status: {account.Status}. Only PENDING accounts can be rejected.");
                }
                
                if (string.IsNullOrWhiteSpace(reason))
                {
                    return Error("Rejection reason is required");
                }
                
                bool rejected = _accountRepo.RejectAccount(accountId, rejectedBy, reason);
                
                if (rejected)
                {
                    string accountTypeName = account.AccountType == "FIXED-DEPOSIT" ? "Fixed Deposit" : 
                                            account.AccountType == "LOAN" ? "Loan" : account.AccountType;
                    return Success($"{accountTypeName} account {accountId} rejected. Reason: {reason}");
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
        /// Get all pending accounts for manager approval
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
                var customer = _customerRepo.GetCustomerById(account.CustomerID);
                if (customer != null)
                {
                    dto.CustomerName = customer.Custname;
                }
                
                // Get account-specific details
                if (account.AccountType == "FIXED-DEPOSIT")
                {
                    var fdAccount = _fdRepo.GetFDAccountById(account.AccountID);
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
                    var loanAccount = _loanRepo.GetLoanAccountById(account.AccountID);
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
        
        /// <summary>
        /// Get count of pending approvals
        /// </summary>
        public int GetPendingApprovalCount()
        {
            try
            {
                var pendingAccounts = _accountRepo.GetPendingAccounts();
                return pendingAccounts?.Count ?? 0;
            }
            catch
            {
                return 0;
            }
        }

        private AccountOperationResult Error(string message) => 
            new AccountOperationResult { IsSuccess = false, Message = message };
        
        private AccountOperationResult Success(string message) => 
            new AccountOperationResult { IsSuccess = true, Message = message };
    }

    /// <summary>
    /// DTO for Account to avoid exposing DB entities to UI layer
    /// </summary>
    public class AccountDTO
    {
        public string AccountID { get; set; }
        public string AccountType { get; set; }
        public string CustomerID { get; set; }
        public string OpenedBy { get; set; }
        public string OpenedByRole { get; set; }
        public DateTime OpenDate { get; set; }
        public string Status { get; set; }
        public DateTime? ClosedDate { get; set; }
        public string RejectionReason { get; set; }  // NEW: Add rejection reason property
    }

    /// <summary>
    /// DTO for Customer Profile
    /// </summary>
    public class CustomerProfileDTO
    {
        public string Custid { get; set; }
        public string Custname { get; set; }
        public DateTime? DOB { get; set; }
        public string Pan { get; set; }
        public string Address { get; set; }
        public string PhoneNumber { get; set; }
    }

    /// <summary>
    /// DTO for Account Details with type-specific information
    /// </summary>
    public class AccountDetailsDTO
    {
        public string AccountID { get; set; }
        public string AccountType { get; set; }
        
        // Savings Account
        public decimal Balance { get; set; }
        
        // Fixed Deposit
        public decimal Amount { get; set; }
        public decimal MaturityAmount { get; set; }
        
        // Loan
        public decimal LoanAmount { get; set; }
        public decimal EMI { get; set; }
        
        // Common
        public decimal InterestRate { get; set; }
        public int Tenure { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
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
        
        /// <summary>
        /// Get the label for "By" column - shows role + ID
        /// Examples: "Manager (MGR001)", "Employee (EMP001)"
        /// </summary>
        public string RequestedByDisplay
        {
         get
            {
 if (string.IsNullOrEmpty(OpenedByRole))
  return OpenedBy;
              
      // Format: "MANAGER (ID)" or "EMPLOYEE (ID)" or capitalize first letter
    string roleLabel = System.Globalization.CultureInfo.CurrentCulture.TextInfo
     .ToTitleCase(OpenedByRole.ToLower());
 return $"{roleLabel} ({OpenedBy})";
        }
        }
    }
}

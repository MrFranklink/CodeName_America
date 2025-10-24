using System;
using System.Collections.Generic;
using System.Linq;

namespace DB
{
    public class AccountRepository
    {
        /// <summary>
        /// Create a new account entry in the Account table
        /// </summary>
        public bool CreateAccount(string accountId, string accountType, string customerId, string openedBy, string openedByRole)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    // Debug logging
                    System.Diagnostics.Debug.WriteLine("=== CreateAccount Called ===");
                    System.Diagnostics.Debug.WriteLine($"AccountID: '{accountId}'");
                    System.Diagnostics.Debug.WriteLine($"AccountType: '{accountType}'");
                    System.Diagnostics.Debug.WriteLine($"CustomerID: '{customerId}'");
                    System.Diagnostics.Debug.WriteLine($"OpenedBy: '{openedBy}' (Length: {openedBy?.Length ?? 0})");
                    System.Diagnostics.Debug.WriteLine($"OpenedByRole: '{openedByRole}' (Length: {openedByRole?.Length ?? 0})");
                    
                    // Check if account already exists
                    if (context.Accounts.Any(a => a.AccountID == accountId))
                    {
                        System.Diagnostics.Debug.WriteLine("ERROR: Account already exists");
                        return false;
                    }

                    var newAccount = new Account
                    {
                        AccountID = accountId,
                        AccountType = accountType,
                        CustomerID = customerId,
                        OpenedBy = openedBy,
                        OpenedByRole = openedByRole,
                        OpenDate = DateTime.Now,
                        Status = "OPEN"
                    };

                    context.Accounts.Add(newAccount);
                    context.SaveChanges();
                    
                    System.Diagnostics.Debug.WriteLine("SUCCESS: Account created");
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR: {ex.Message}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"INNER: {ex.InnerException.Message}");
                }
                System.Diagnostics.Debug.WriteLine($"STACK: {ex.StackTrace}");
                return false;
            }
        }

        /// <summary>
        /// Close an account
        /// </summary>
        public bool CloseAccount(string accountId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    var account = context.Accounts.Find(accountId);
                    if (account == null || account.Status == "CLOSED")
                    {
                        return false;
                    }

                    account.Status = "CLOSED";
                    account.ClosedDate = DateTime.Now;
                    context.SaveChanges();
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Get all accounts
        /// </summary>
        public List<Account> GetAllAccounts()
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Accounts.ToList();
                }
            }
            catch
            {
                return new List<Account>();
            }
        }

        /// <summary>
        /// Get accounts by customer ID
        /// </summary>
        public List<Account> GetAccountsByCustomerId(string customerId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Accounts
                        .Where(a => a.CustomerID == customerId)
                        .ToList();
                }
            }
            catch
            {
                return new List<Account>();
            }
        }

        /// <summary>
        /// Get account by ID
        /// </summary>
        public Account GetAccountById(string accountId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Accounts.Find(accountId);
                }
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Check if customer has account of specific type
        /// </summary>
        public bool CustomerHasAccountType(string customerId, string accountType)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Accounts.Any(a => a.CustomerID == customerId && a.AccountType == accountType && a.Status == "OPEN");
                }
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Get total account count
        /// </summary>
        public int GetTotalAccountCount()
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Accounts.Count(a => a.Status == "OPEN");
                }
            }
            catch
            {
                return 0;
            }
        }

        /// <summary>
        /// Approve a pending account
        /// </summary>
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

        /// <summary>
        /// Reject a pending account
        /// </summary>
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

        /// <summary>
        /// Get all pending accounts (for manager approval)
        /// </summary>
        public List<Account> GetPendingAccounts()
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Accounts
                        .Where(a => a.Status == "PENDING")
                        .OrderByDescending(a => a.OpenDate)
                        .ToList();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR getting pending accounts: {ex.Message}");
                return new List<Account>();
            }
        }

        /// <summary>
        /// Get pending accounts by type (LOAN or FIXED-DEPOSIT)
        /// </summary>
        public List<Account> GetPendingAccountsByType(string accountType)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Accounts
                        .Where(a => a.Status == "PENDING" && a.AccountType == accountType)
                        .OrderByDescending(a => a.OpenDate)
                        .ToList();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"ERROR getting pending accounts by type: {ex.Message}");
                return new List<Account>();
            }
        }

        /// <summary>
        /// Create account with custom status (for approval workflow)
        /// </summary>
        public bool CreateAccountWithStatus(string accountId, string accountType, string customerId, string openedBy, string openedByRole, string status)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    // Debug logging - Log ALL input parameters
                    System.Diagnostics.Debug.WriteLine("=== CreateAccountWithStatus Called ===");
                    System.Diagnostics.Debug.WriteLine($"AccountID: '{accountId}' (Length: {accountId?.Length ?? 0})");
                    System.Diagnostics.Debug.WriteLine($"AccountType: '{accountType}' (Length: {accountType?.Length ?? 0})");
                    System.Diagnostics.Debug.WriteLine($"CustomerID: '{customerId}' (Length: {customerId?.Length ?? 0})");
                    System.Diagnostics.Debug.WriteLine($"OpenedBy: '{openedBy}' (Length: {openedBy?.Length ?? 0})");
                    System.Diagnostics.Debug.WriteLine($"OpenedByRole: '{openedByRole}' (Length: {openedByRole?.Length ?? 0})");
                    System.Diagnostics.Debug.WriteLine($"Status: '{status}' (Length: {status?.Length ?? 0})");

                    // Check if account already exists
                    if (context.Accounts.Any(a => a.AccountID == accountId))
                    {
                        System.Diagnostics.Debug.WriteLine("ERROR: Account already exists");
                        return false;
                    }

                    var account = new Account
                    {
                        AccountID = accountId,
                        AccountType = accountType,
                        CustomerID = customerId,
                        OpenedBy = openedBy,
                        OpenedByRole = openedByRole,
                        OpenDate = DateTime.Now,
                        Status = status  // Can be "PENDING", "OPEN", etc.
                    };

                    System.Diagnostics.Debug.WriteLine("Adding account to context...");
                    context.Accounts.Add(account);
                    
                    System.Diagnostics.Debug.WriteLine("Calling SaveChanges...");
                    context.SaveChanges();
                    
                    System.Diagnostics.Debug.WriteLine("SUCCESS: Account created with status");
                    return true;
                }
            }
            catch (System.Data.Entity.Validation.DbEntityValidationException validationEx)
            {
                System.Diagnostics.Debug.WriteLine("=== VALIDATION ERROR ===");
                foreach (var validationErrors in validationEx.EntityValidationErrors)
                {
                    System.Diagnostics.Debug.WriteLine($"Entity: {validationErrors.Entry.Entity.GetType().Name}");
                    foreach (var validationError in validationErrors.ValidationErrors)
                    {
                        System.Diagnostics.Debug.WriteLine($"  Property: {validationError.PropertyName}");
                        System.Diagnostics.Debug.WriteLine($"  Error: {validationError.ErrorMessage}");
                    }
                }
                return false;
            }
            catch (System.Data.Entity.Infrastructure.DbUpdateException dbEx)
            {
                System.Diagnostics.Debug.WriteLine("=== DB UPDATE ERROR ===");
                System.Diagnostics.Debug.WriteLine($"ERROR: {dbEx.Message}");
                
                // Log all inner exceptions
                var innerException = dbEx.InnerException;
                int level = 1;
                while (innerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"INNER EXCEPTION (Level {level}): {innerException.Message}");
                    
                    // Check for SQL exception
                    if (innerException is System.Data.SqlClient.SqlException sqlEx)
                    {
                        System.Diagnostics.Debug.WriteLine($"SQL Error Number: {sqlEx.Number}");
                        System.Diagnostics.Debug.WriteLine($"SQL Error State: {sqlEx.State}");
                        System.Diagnostics.Debug.WriteLine($"SQL Error Class: {sqlEx.Class}");
                        System.Diagnostics.Debug.WriteLine($"SQL Line Number: {sqlEx.LineNumber}");
                        System.Diagnostics.Debug.WriteLine($"SQL Procedure: {sqlEx.Procedure}");
                        System.Diagnostics.Debug.WriteLine($"SQL Server: {sqlEx.Server}");
                    }
                    
                    innerException = innerException.InnerException;
                    level++;
                }
                
                System.Diagnostics.Debug.WriteLine($"STACK: {dbEx.StackTrace}");
                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("=== GENERAL ERROR ===");
                System.Diagnostics.Debug.WriteLine($"ERROR: {ex.Message}");
                
                // Log all inner exceptions
                var innerException = ex.InnerException;
                int level = 1;
                while (innerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"INNER {level}: {innerException.Message}");
                    innerException = innerException.InnerException;
                    level++;
                }
                
                System.Diagnostics.Debug.WriteLine($"STACK: {ex.StackTrace}");
                return false;
            }
        }
    }
}

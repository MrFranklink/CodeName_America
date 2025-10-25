using System;
using System.Collections.Generic;
using System.Linq;

namespace DB
{
    public class ManagerRepository
    {
        public bool CreateManager(string managerId, string managerName, string pan)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    // Check if manager already exists
                    if (context.Managers.Any(m => m.ManagerID == managerId))
                    {
                        return false;
                    }

                    var newManager = new Manager
                    {
                        ManagerID = managerId,
                        ManagerName = managerName,
                        PAN = pan
                    };

                    context.Managers.Add(newManager);
                    context.SaveChanges();
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }

        public List<Manager> GetAllManagers()
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Managers.ToList();
                }
            }
            catch
            {
                return new List<Manager>();
            }
        }

        public Manager GetManagerById(string managerId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Managers.FirstOrDefault(m => m.ManagerID == managerId);
                }
            }
            catch
            {
                return null;
            }
        }

        public bool ManagerExists(string managerId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Managers.Any(m => m.ManagerID == managerId);
                }
            }
            catch
            {
                return false;
            }
        }

        public int GetManagerCount()
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Managers.Count();
                }
            }
            catch
            {
                return 0;
            }
        }

        public bool DeleteManager(string managerId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    var manager = context.Managers.Find(managerId);
                    if (manager == null)
                    {
                        return false;
                    }

                    context.Managers.Remove(manager);
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
        /// Delete a customer (UserLogin deleted automatically by database trigger)
        /// Validates that customer has NO open Savings, Fixed Deposit, or Loan accounts
        /// Automatically deletes CLOSED account records before deleting customer
        /// </summary>
        /// <param name="customerId">Customer ID to delete</param>
        /// <returns>Operation result</returns>
        public DeleteOperationResult DeleteCustomer(string customerId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    var customer = context.Customers.Find(customerId);
                    if (customer == null)
                    {
                        return new DeleteOperationResult
                        {
                            IsSuccess = false,
                            Message = $"Customer {customerId} not found"
                        };
                    }

                    // Check for open Savings accounts
                    var openSavingsAccounts = context.Accounts
                        .Where(a => a.CustomerID == customerId && a.AccountType == "SAVING" && a.Status == "OPEN")
                        .ToList();

                    // Check for open Fixed Deposit accounts
                    var openFDAccounts = context.Accounts
                        .Where(a => a.CustomerID == customerId && a.AccountType == "FIXED-DEPOSIT" && a.Status == "OPEN")
                        .ToList();

                    // Check for open Loan accounts
                    var openLoanAccounts = context.Accounts
                        .Where(a => a.CustomerID == customerId && a.AccountType == "LOAN" && a.Status == "OPEN")
                        .ToList();

                    // Check for pending accounts (PENDING status)
                    var pendingAccounts = context.Accounts
                        .Where(a => a.CustomerID == customerId && a.Status == "PENDING")
                        .ToList();

                    // Build detailed error message
                    var accountIssues = new List<string>();
                    
                    if (openSavingsAccounts.Any())
                    {
                        accountIssues.Add($"{openSavingsAccounts.Count} Savings account(s): {string.Join(", ", openSavingsAccounts.Select(a => a.AccountID))}");
                    }
                    
                    if (openFDAccounts.Any())
                    {
                        accountIssues.Add($"{openFDAccounts.Count} Fixed Deposit(s): {string.Join(", ", openFDAccounts.Select(a => a.AccountID))}");
                    }
                    
                    if (openLoanAccounts.Any())
                    {
                        accountIssues.Add($"{openLoanAccounts.Count} Loan account(s): {string.Join(", ", openLoanAccounts.Select(a => a.AccountID))}");
                    }
                    
                    if (pendingAccounts.Any())
                    {
                        accountIssues.Add($"{pendingAccounts.Count} Pending application(s): {string.Join(", ", pendingAccounts.Select(a => a.AccountID))}");
                    }

                    if (accountIssues.Any())
                    {
                        return new DeleteOperationResult
                        {
                            IsSuccess = false,
                            Message = $"Cannot delete customer {customerId}. Customer has active accounts:\n" +
                                     string.Join("\n", accountIssues) + 
                                     "\n\nPlease close/foreclose all accounts before deleting the customer."
                        };
                    }

                    // ============================================================
                    // NEW: Delete all CLOSED/REJECTED account records before deleting customer
                    // ============================================================
                    
                    // Get all CLOSED and REJECTED accounts for this customer
                    var closedAccounts = context.Accounts
                        .Where(a => a.CustomerID == customerId && 
                               (a.Status == "CLOSED" || a.Status == "REJECTED"))
                        .ToList();
                    
                    if (closedAccounts.Any())
                    {
                        System.Diagnostics.Debug.WriteLine($"Found {closedAccounts.Count} closed/rejected accounts to delete");
                        
                        foreach (var account in closedAccounts)
                        {
                            // Delete child records first (to avoid FK constraint violations)
                            
                            // Delete SavingsAccount records
                            if (account.AccountType == "SAVING")
                            {
                                var savingsAccount = context.SavingsAccounts.Find(account.AccountID);
                                if (savingsAccount != null)
                                {
                                    // Delete SavingsTransactions
                                    var transactions = context.SavingsTransactions
                                        .Where(t => t.SBAccountID == account.AccountID)
                                        .ToList();
                                    context.SavingsTransactions.RemoveRange(transactions);
                                    
                                    // Delete FundTransfers (as sender)
                                    var transfersFrom = context.FundTransfers
                                        .Where(f => f.FromAccountID == account.AccountID)
                                        .ToList();
                                    context.FundTransfers.RemoveRange(transfersFrom);
                                    
                                    // Delete FundTransfers (as receiver)
                                    var transfersTo = context.FundTransfers
                                        .Where(f => f.ToAccountID == account.AccountID)
                                        .ToList();
                                    context.FundTransfers.RemoveRange(transfersTo);
                                    
                                    // Delete SavingsAccount
                                    context.SavingsAccounts.Remove(savingsAccount);
                                    System.Diagnostics.Debug.WriteLine($"Deleted SavingsAccount: {account.AccountID}");
                                }
                            }
                            
                            // Delete FixedDepositAccount records
                            else if (account.AccountType == "FIXED-DEPOSIT")
                            {
                                var fdAccount = context.FixedDepositAccounts.Find(account.AccountID);
                                if (fdAccount != null)
                                {
                                    // NEW: Delete FDTransactions first
                                    var fdTransactions = context.FDTransactions
                                        .Where(t => t.FDAccountID == account.AccountID)
                                        .ToList();
                                    context.FDTransactions.RemoveRange(fdTransactions);
                                    
                                    // Delete FixedDepositAccount
                                    context.FixedDepositAccounts.Remove(fdAccount);
                                    System.Diagnostics.Debug.WriteLine($"Deleted FixedDepositAccount: {account.AccountID}");
                                }
                            }
                            
                            // Delete LoanAccount records
                            else if (account.AccountType == "LOAN")
                            {
                                var loanAccount = context.LoanAccounts.Find(account.AccountID);
                                if (loanAccount != null)
                                {
                                    // Delete LoanTransactions
                                    var loanTransactions = context.LoanTransactions
                                        .Where(t => t.Ln_accountid == account.AccountID)
                                        .ToList();
                                    context.LoanTransactions.RemoveRange(loanTransactions);
                                    
                                    // Delete LoanAccount
                                    context.LoanAccounts.Remove(loanAccount);
                                    System.Diagnostics.Debug.WriteLine($"Deleted LoanAccount: {account.AccountID}");
                                }
                            }
                            
                            // Delete the Account record itself
                            context.Accounts.Remove(account);
                            System.Diagnostics.Debug.WriteLine($"Deleted Account: {account.AccountID}");
                        }
                        
                        // Save deletions of closed accounts
                        context.SaveChanges();
                        System.Diagnostics.Debug.WriteLine($"Deleted {closedAccounts.Count} closed/rejected accounts");
                    }

                    // ============================================================
                    // Now safe to delete customer (trigger will delete UserLogin)
                    // ============================================================
                    
                    context.Customers.Remove(customer);
                    context.SaveChanges();

                    string message = $"Customer {customerId} deleted successfully.";
                    if (closedAccounts.Any())
                    {
                        message += $" Also deleted {closedAccounts.Count} closed account(s).";
                    }
                    message += " User login credentials automatically removed by database trigger.";

                    return new DeleteOperationResult
                    {
                        IsSuccess = true,
                        Message = message
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting customer: {ex.Message}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {ex.InnerException.Message}");
                }
                
                return new DeleteOperationResult
                {
                    IsSuccess = false,
                    Message = $"Failed to delete customer: {ex.Message}"
                };
            }
        }

        /// <summary>
        /// Delete an employee (UserLogin deleted automatically by database trigger)
        /// Validates that employee has no open accounts they've created
        /// Automatically deletes CLOSED account records before deleting employee
        /// </summary>
        /// <param name="employeeId">Employee ID to delete</param>
        /// <returns>Operation result</returns>
        public DeleteOperationResult DeleteEmployee(string employeeId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    var employee = context.Employees.Find(employeeId);
                    if (employee == null)
                    {
                        return new DeleteOperationResult
                        {
                            IsSuccess = false,
                            Message = $"Employee {employeeId} not found"
                        };
                    }

                    // Check if employee has opened any accounts that are still open
                    var openAccountsCreated = context.Accounts
                        .Where(a => a.OpenedBy == employeeId && a.Status == "OPEN")
                        .ToList();

                    // Check if employee has pending approvals
                    var pendingAccountsCreated = context.Accounts
                        .Where(a => a.OpenedBy == employeeId && a.Status == "PENDING")
                        .ToList();

                    var accountIssues = new List<string>();
                    
                    if (openAccountsCreated.Any())
                    {
                        var groupedByType = openAccountsCreated.GroupBy(a => a.AccountType);
                        foreach (var group in groupedByType)
                        {
                            accountIssues.Add($"{group.Count()} {group.Key} account(s): {string.Join(", ", group.Select(a => a.AccountID))}");
                        }
                    }
                    
                    if (pendingAccountsCreated.Any())
                    {
                        accountIssues.Add($"{pendingAccountsCreated.Count} Pending application(s): {string.Join(", ", pendingAccountsCreated.Select(a => a.AccountID))}");
                    }

                    if (accountIssues.Any())
                    {
                        return new DeleteOperationResult
                        {
                            IsSuccess = false,
                            Message = $"Cannot delete employee {employeeId}. Employee has created accounts that are still active:\n" +
                                     string.Join("\n", accountIssues) + 
                                     "\n\nPlease close those accounts first or reassign them to another employee."
                        };
                    }

                    // All checks passed - safe to delete
                    // Note: Closed accounts created by this employee will remain (they belong to customers)
                    // Only the employee record and their UserLogin will be deleted
                    
                    context.Employees.Remove(employee);
                    context.SaveChanges();

                    return new DeleteOperationResult
                    {
                        IsSuccess = true,
                        Message = $"Employee {employeeId} deleted successfully. User login credentials automatically removed by database trigger."
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error deleting employee: {ex.Message}");
                if (ex.InnerException != null)
                {
                    System.Diagnostics.Debug.WriteLine($"Inner exception: {ex.InnerException.Message}");
                }
                
                return new DeleteOperationResult
                {
                    IsSuccess = false,
                    Message = $"Failed to delete employee: {ex.Message}"
                };
            }
        }
    }

    /// <summary>
    /// Result object for delete operations
    /// </summary>
    public class DeleteOperationResult
    {
        public bool IsSuccess { get; set; }
        public string Message { get; set; }
    }
}

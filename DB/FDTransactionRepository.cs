using System;
using System.Collections.Generic;
using System.Linq;

namespace DB
{
    public class FDTransactionRepository
    {
        /// <summary>
        /// Create a new FD transaction record
        /// </summary>
        public bool CreateFDTransaction(string fdAccountId, string transactionType, decimal amount)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    // Get the next transaction ID (since it's not auto-increment)
                    int nextId = 1;
                    var lastTransaction = context.FDTransactions
                        .OrderByDescending(t => t.TransactionID)
                        .FirstOrDefault();
                    
                    if (lastTransaction != null)
                    {
                        nextId = lastTransaction.TransactionID + 1;
                    }

                    var transaction = new FDTransaction
                    {
                        TransactionID = nextId,
                        FDAccountID = fdAccountId,
                        TransactionType = transactionType,
                        Amount = amount,
                        TransactionDate = DateTime.Now
                    };

                    context.FDTransactions.Add(transaction);
                    context.SaveChanges();
                    
                    System.Diagnostics.Debug.WriteLine($"FD Transaction recorded: ID={nextId}, Type={transactionType}, Amount={amount}");
                    return true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error creating FD transaction: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Get all transactions for a specific FD account
        /// </summary>
        public List<FDTransaction> GetFDTransactionsByAccountId(string fdAccountId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.FDTransactions
                        .Where(t => t.FDAccountID == fdAccountId)
                        .OrderBy(t => t.TransactionDate)
                        .ToList();
                }
            }
            catch
            {
                return new List<FDTransaction>();
            }
        }

        /// <summary>
        /// Get all FD transactions
        /// </summary>
        public List<FDTransaction> GetAllFDTransactions()
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.FDTransactions
                        .OrderByDescending(t => t.TransactionDate)
                        .ToList();
                }
            }
            catch
            {
                return new List<FDTransaction>();
            }
        }
    }
}

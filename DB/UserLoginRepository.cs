using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DB.Utilities;

namespace DB
{
    public class UserLoginRepository
    {
        public UserLogin GetUserByUsername(string username)
        {
            using (var context = new Banking_DetailsEntities())
            {
                return context.UserLogins
                    .FirstOrDefault(u => u.UserName == username);
            }
        }

        public UserLogin GetUserByUserId(string userId)
        {
            using (var context = new Banking_DetailsEntities())
            {
                return context.UserLogins
                    .FirstOrDefault(u => u.UserID == userId);
            }
        }

        public bool UsernameExists(string username)
        {
            using (var context = new Banking_DetailsEntities())
            {
                return context.UserLogins.Any(u => u.UserName == username);
            }
        }

        public bool UserIdExists(string userId)
        {
            using (var context = new Banking_DetailsEntities())
            {
                return context.UserLogins.Any(u => u.UserID == userId);
            }
        }

        public bool CreateUser(string userId, string userName, string password, string role, string referenceId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    var newUser = new UserLogin
                    {
                        UserID = userId,
                        UserName = userName,
                        PasswordHash = PasswordHelper.HashPassword(password), // Hash the password
                        Role = role,
                        ReferenceID = referenceId
                    };

                    context.UserLogins.Add(newUser);
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
        /// Update user password (hashed)
        /// </summary>
        public bool UpdatePassword(string userId, string newPassword)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    var user = context.UserLogins.FirstOrDefault(u => u.UserID == userId);
                    if (user == null)
                        return false;

                    user.PasswordHash = PasswordHelper.HashPassword(newPassword);
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
        /// Delete user login by UserID
        /// </summary>
        /// <param name="userId">UserID to delete</param>
        /// <returns>True if deleted successfully</returns>
        public bool DeleteUser(string userId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    var user = context.UserLogins.FirstOrDefault(u => u.UserID == userId);
                    if (user == null)
                        return false;

                    context.UserLogins.Remove(user);
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
        /// Delete user login by ReferenceID (Customer ID, Employee ID, or Manager ID)
        /// This is used when deleting a customer, employee, or manager
        /// </summary>
        /// <param name="referenceId">ReferenceID (e.g., MLA00001, 2600001, MGR001)</param>
        /// <returns>True if deleted successfully</returns>
        public bool DeleteUserByReferenceId(string referenceId)
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    var user = context.UserLogins.FirstOrDefault(u => u.ReferenceID == referenceId);
                    if (user == null)
                        return false; // No login found for this reference ID

                    context.UserLogins.Remove(user);
                    context.SaveChanges();
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }

        public bool TestConnection()
        {
            try
            {
                using (var context = new Banking_DetailsEntities())
                {
                    return context.Database.Exists();
                }

            }
            catch
            {
                return false;
            }
        }

    }

}


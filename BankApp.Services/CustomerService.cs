using System;
using System.Collections.Generic;
using System.Linq;
using DB;
using DB.Utilities;

namespace BankApp.Services
{
    public class CustomerService
    {
        private readonly CustomerRepository _customerRepo;
        private readonly EmployeeRepository _employeeRepo;
        private readonly ManagerRepository _managerRepo;
        private readonly UserLoginRepository _userLoginRepo;

        public CustomerService()
        {
            _customerRepo = new CustomerRepository();
            _employeeRepo = new EmployeeRepository();
            _managerRepo = new ManagerRepository();
            _userLoginRepo = new UserLoginRepository();
        }

        /// <summary>
        /// Register a new customer with auto-generated ID and UserLogin
        /// </summary>
        public OperationResult RegisterCustomer(string custName, DateTime dob, string pan, string address, string phoneNumber)
        {
            // Clean and normalize inputs
            custName = custName?.Trim();
            pan = pan?.ToUpper().Trim();
            phoneNumber = phoneNumber?.Trim();
            address = address?.Trim();

            var validationRules = new List<Func<OperationResult>>
            {
                // Customer Name validations
                () => string.IsNullOrWhiteSpace(custName) ? Error("Customer Name is required") : null,
                () => custName.Length < 3 ? Error("Customer Name must be at least 3 characters long") : null,
                () => custName.Length > 50 ? Error("Customer Name cannot exceed 50 characters") : null,
                () => !System.Text.RegularExpressions.Regex.IsMatch(custName, @"^[a-zA-Z\s.]+$") 
                    ? Error("Customer Name can only contain letters, spaces, and dots (.)") : null,
                
                // PAN validations
                () => string.IsNullOrWhiteSpace(pan) ? Error("PAN is required") : null,
                () => !IdGenerator.ValidatePanFormat(pan) ? Error("PAN must be in format: 5 letters + 4 digits + 1 letter (e.g., ABCDE1234F)") : null,
                () => _customerRepo.PanExists(pan) ? Error($"PAN number '{pan}' is already registered with another customer. Each PAN can only be used once.") : null,
                () => _employeeRepo.PanExists(pan) ? Error($"PAN number '{pan}' is already registered as an employee. Same person cannot be both customer and employee.") : null,
                
                // Phone Number validations
                () => string.IsNullOrWhiteSpace(phoneNumber) ? Error("Phone Number is required") : null,
                () => !System.Text.RegularExpressions.Regex.IsMatch(phoneNumber, @"^[6-9][0-9]{9}$") 
                    ? Error("Phone Number must be a valid 10-digit Indian mobile number starting with 6, 7, 8, or 9 (e.g., 9876543210)") : null,
                
                // Address validations
                () => string.IsNullOrWhiteSpace(address) ? Error("Address is required") : null,
                () => address.Length < 10 ? Error("Address must be at least 10 characters long") : null,
                () => address.Length > 100 ? Error("Address cannot exceed 100 characters") : null,
                
                // Date of Birth validations
                () => dob > DateTime.Now ? Error("Date of Birth cannot be in the future") : null,
                () => dob > DateTime.Now.AddYears(-18) ? Error("Customer must be at least 18 years old") : null,
                () => dob < DateTime.Now.AddYears(-100) ? Error("Please enter a valid Date of Birth (age cannot exceed 100 years)") : null
            };

            var validationError = validationRules.Select(rule => rule()).FirstOrDefault(result => result != null);
            if (validationError != null) return validationError;

            try
            {
                // Auto-generate Customer ID
                string custId = IdGenerator.GenerateCustomerId();

                // Create customer
                bool customerCreated = _customerRepo.CreateCustomer(custId, custName, dob, pan, address, phoneNumber);
                
                if (!customerCreated)
                {
                    return Error("Failed to register customer. Please try again.");
                }

                // Auto-generate username from first name
                string username = IdGenerator.GenerateUsername(custName.Split(' ')[0]);

                // Generate UNIQUE UserID for login (different from Customer ID)
                string userId = IdGenerator.GenerateUserId();

                // Create UserLogin with default password
                string defaultPassword = "Dummy";
                // UserID = unique login ID, ReferenceID = Customer ID
                bool loginCreated = _userLoginRepo.CreateUser(userId, username, defaultPassword, "CUSTOMER", custId);

                if (!loginCreated)
                {
                    // Rollback: Delete the customer if login creation failed
                    // Note: In production, use transactions
                    return Error("Customer created but login failed. Please contact administrator.");
                }

                return Success($"Customer registered successfully! Customer ID: {custId}, Username: {username}, Password: {defaultPassword}", custId, username, defaultPassword);
            }
            catch (Exception ex)
            {
                return Error($"Registration failed: {ex.Message}");
            }
        }

        public List<CustomerDTO> GetAllCustomers()
        {
            var customers = _customerRepo.GetAllCustomers();
            return customers.Select(c => new CustomerDTO
            {
                Custid = c.Custid,
                Custname = c.Custname,
                DOB = c.DOB,
                Pan = c.Pan,
                Address = c.Address,
                PhoneNumber = c.PhoneNumber
            }).ToList();
        }

        public int GetCustomerCount()
        {
            return _customerRepo.GetCustomerCount();
        }

        /// <summary>
        /// Update customer profile (Name, Address, Phone)
        /// PAN and DOB cannot be changed
        /// </summary>
        public OperationResult UpdateCustomer(string custId, string custName, string address, string phoneNumber)
        {
            // Clean and normalize inputs
            custName = custName?.Trim();
            phoneNumber = phoneNumber?.Trim();
            address = address?.Trim();

            var validationRules = new List<Func<OperationResult>>
            {
                // Customer ID validation
                () => string.IsNullOrWhiteSpace(custId) ? Error("Customer ID is required") : null,
                
                // Customer Name validations
                () => string.IsNullOrWhiteSpace(custName) ? Error("Customer Name is required") : null,
                () => custName.Length < 3 ? Error("Customer Name must be at least 3 characters long") : null,
                () => custName.Length > 50 ? Error("Customer Name cannot exceed 50 characters") : null,
                () => !System.Text.RegularExpressions.Regex.IsMatch(custName, @"^[a-zA-Z\s.]+$") 
                    ? Error("Customer Name can only contain letters, spaces, and dots (.)") : null,
                
                // Phone Number validations
                () => string.IsNullOrWhiteSpace(phoneNumber) ? Error("Phone Number is required") : null,
                () => !System.Text.RegularExpressions.Regex.IsMatch(phoneNumber, @"^[6-9][0-9]{9}$") 
                    ? Error("Phone Number must be a valid 10-digit Indian mobile number starting with 6, 7, 8, or 9") : null,
                
                // Address validations
                () => string.IsNullOrWhiteSpace(address) ? Error("Address is required") : null,
                () => address.Length < 10 ? Error("Address must be at least 10 characters long") : null,
                () => address.Length > 100 ? Error("Address cannot exceed 100 characters") : null
            };

            var validationError = validationRules.Select(rule => rule()).FirstOrDefault(result => result != null);
            if (validationError != null) return validationError;

            try
            {
                // Check if customer exists
                if (!_customerRepo.CustomerExists(custId))
                {
                    return Error($"Customer with ID {custId} not found");
                }

                // Update customer
                bool updated = _customerRepo.UpdateCustomer(custId, custName, address, phoneNumber);
                
                if (!updated)
                {
                    return Error("Failed to update customer profile. Please try again.");
                }

                return Success($"Customer profile updated successfully!", custId, null, null);
            }
            catch (Exception ex)
            {
                return Error($"Update failed: {ex.Message}");
            }
        }

        public CustomerDTO GetCustomerById(string custId)
        {
            var customer = _customerRepo.GetCustomerById(custId);
            if (customer == null)
                return null;

            return new CustomerDTO
            {
                Custid = customer.Custid,
                Custname = customer.Custname,
                DOB = customer.DOB,
                Pan = customer.Pan,
                Address = customer.Address,
                PhoneNumber = customer.PhoneNumber
            };
        }

        private OperationResult Error(string message)
        {
            return new OperationResult
            {
                IsSuccess = false,
                Message = message
            };
        }

        private OperationResult Success(string message, string generatedId, string generatedUsername, string generatedPassword)
        {
            return new OperationResult
            {
                IsSuccess = true,
                Message = message,
                GeneratedId = generatedId,
                GeneratedUsername = generatedUsername,
                GeneratedPassword = generatedPassword
            };
        }
    }

    // DTO to avoid exposing DB entities
    public class CustomerDTO
    {
        public string Custid { get; set; }
        public string Custname { get; set; }
        public DateTime? DOB { get; set; }
        public string Pan { get; set; }
        public string Address { get; set; }
        public string PhoneNumber { get; set; }
    }

    public class OperationResult
    {
        public bool IsSuccess { get; set; }
        public string Message { get; set; }
        public string GeneratedId { get; set; }
        public string GeneratedUsername { get; set; }
        public string GeneratedPassword { get; set; }
    }
}

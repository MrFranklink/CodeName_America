# ?? Quick Test Guide - Edit Customer & Employee Feature

## ? Fast Testing Steps

### Test Edit Customer (2 minutes)
```
1. Login as Manager
2. Click "Customers" tab
3. Click "Edit" button on any customer
4. Change name/address/phone
5. Click "Update Profile"
6. ? Success message should appear
7. ? Table should reflect changes
```

### Test Edit Employee (2 minutes)
```
1. Stay logged in as Manager
2. Click "Employees" tab
3. Click "Edit" button on any employee
4. Change name or department
5. Click "Update Information"
6. ? Success message should appear
7. ? Table should reflect changes
```

## ?? What to Look For

### Visual Checks
- ? Edit button is BEFORE Delete button
- ? Edit button has blue color (`btn-primary`)
- ? Edit button has pencil icon
- ? Modal opens smoothly
- ? Modal header is blue
- ? Info alert is visible (PAN/DOB cannot be changed)

### Data Checks
- ? Customer ID is pre-filled (hidden)
- ? Name is pre-filled
- ? Address is pre-filled (customers only)
- ? Phone is pre-filled (customers only)
- ? Department is pre-selected (employees only)

### Functionality Checks
- ? Cancel button closes modal
- ? Submit button updates data
- ? Success message appears on submit
- ? Table refreshes with new data
- ? Required validation works

## ?? Known Success Indicators

### Edit Customer Success
```
? Success message: "Customer [ID] updated successfully"
? Name changed in table
? Address changed (visible in details)
? Phone changed (visible in table)
```

### Edit Employee Success
```
? Success message: "Employee [ID] updated successfully"
? Name changed in table
? Department badge changed color/text
```

## ?? Red Flags (What Should NOT Happen)

### Don't See These Errors
- ? JavaScript errors in console
- ? "Modal not defined" error
- ? Form fields not pre-filled
- ? Submit does nothing
- ? Page crashes or freezes
- ? Data not saved after submit

## ?? Quick Fixes

### If Modal Doesn't Open
```
1. Press F12 (open browser console)
2. Look for JavaScript errors
3. Check if Bootstrap is loaded:
   - Type: bootstrap.Modal
   - Should return: function
```

### If Data Doesn't Save
```
1. Check Network tab (F12 ? Network)
2. Look for POST request to /Dashboard/UpdateCustomer or /Dashboard/UpdateEmployee
3. Check Response tab for error message
4. Verify Session is not expired
```

### If Form is Empty
```
1. Right-click Edit button ? Inspect
2. Check onclick attribute
3. Verify parameters are passed:
   - Customer: custId, custName, address, phoneNumber
   - Employee: empId, empName, deptId
```

## ?? Test Matrix

| Test Case | Expected Result | Status |
|-----------|----------------|--------|
| Edit Customer - Valid Data | Success message + table update | ? |
| Edit Customer - Empty Name | Browser validation error | ? |
| Edit Customer - Invalid Phone | Browser validation error | ? |
| Edit Customer - Cancel | Modal closes, no changes | ? |
| Edit Employee - Valid Data | Success message + table update | ? |
| Edit Employee - Empty Name | Browser validation error | ? |
| Edit Employee - No Department | Browser validation error | ? |
| Edit Employee - Cancel | Modal closes, no changes | ? |

## ?? Final Checklist

Before marking as complete:

- [ ] Edit button visible on Customers table
- [ ] Edit button visible on Employees table
- [ ] Edit Customer modal opens
- [ ] Edit Employee modal opens
- [ ] Customer data pre-fills correctly
- [ ] Employee data pre-fills correctly
- [ ] Customer update saves successfully
- [ ] Employee update saves successfully
- [ ] Success messages appear
- [ ] Table refreshes with new data
- [ ] Cancel button works
- [ ] Form validation works
- [ ] No JavaScript errors in console

## ?? Test Results Template

```
Test Date: _______________
Tester: _______________

Edit Customer Feature:
? / ? Button visible
? / ? Modal opens
? / ? Data pre-fills
? / ? Update saves
? / ? Success message

Edit Employee Feature:
? / ? Button visible
? / ? Modal opens
? / ? Data pre-fills
? / ? Update saves
? / ? Success message

Issues Found:
1. ___________________
2. ___________________
3. ___________________

Notes:
___________________________
___________________________
___________________________
```

---

**Quick Reference:** Keep this document open while testing for instant troubleshooting!

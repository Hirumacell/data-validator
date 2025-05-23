import unittest
import os
import json
from src.validator import DataValidator

class TestDataValidator(unittest.TestCase):

    def setUp(self):
        self.validator = DataValidator()
        self.test_data_dir = os.path.join(os.path.dirname(__file__), 'test_data')

    def test_valid_data_file(self):
        """Test validation with valid data file"""
        valid_file = os.path.join(self.test_data_dir, 'valid_data.json')
        self.validator.file_path = valid_file
        result = self.validator.validate()
        self.assertTrue(result['is_valid'])
        self.assertEqual(len(result['errors']), 0)
        self.assertEqual(result['summary']['total_valid'], 4)

    def test_invalid_data_file(self):
        """Test validation with invalid data file"""
        invalid_file = os.path.join(self.test_data_dir, 'invalid_data.json')
        self.validator.file_path = invalid_file
        result = self.validator.validate()
        self.assertFalse(result['is_valid'])
        self.assertGreater(len(result['errors']), 0)

    def test_valid_data_direct(self):
        """Test validation with valid data passed directly"""
        valid_data = [
            {"name": "John Doe", "email": "john.doe@example.com", "age": 30, "registration_date": "2023-01-15"},
            {"name": "Jane Smith", "email": "jane.smith@example.com", "age": 25, "registration_date": "2023-02-20"}
        ]
        result = self.validator.validate(valid_data)
        self.assertTrue(result['is_valid'])
        self.assertEqual(len(result['errors']), 0)
        self.assertEqual(result['summary']['total_valid'], 2)

    def test_invalid_email_format(self):
        """Test detection of invalid email format"""
        invalid_data = [
            {"name": "Invalid User", "email": "invalid-email", "age": 25, "registration_date": "2023-01-15"}
        ]
        result = self.validator.validate(invalid_data)
        self.assertFalse(result['is_valid'])
        self.assertTrue(any("Invalid email format" in error for error in result['errors']))

    def test_negative_age(self):
        """Test detection of negative age"""
        invalid_data = [
            {"name": "Young User", "email": "young@example.com", "age": -5, "registration_date": "2023-01-15"}
        ]
        result = self.validator.validate(invalid_data)
        self.assertFalse(result['is_valid'])
        self.assertTrue(any("Age cannot be negative" in error for error in result['errors']))

    def test_missing_values(self):
        """Test detection of missing required fields"""
        data_with_missing_values = [
            {"name": "Missing Age", "email": "missing.age@example.com", "registration_date": "2023-01-15"},
            {"name": "Missing Email", "age": 22, "registration_date": "2023-01-15"}
        ]
        result = self.validator.validate(data_with_missing_values)
        self.assertFalse(result['is_valid'])
        self.assertTrue(any("Missing required field 'age'" in error for error in result['errors']))
        self.assertTrue(any("Missing required field 'email'" in error for error in result['errors']))

    def test_empty_name(self):
        """Test detection of empty name"""
        invalid_data = [
            {"name": "", "email": "empty.name@example.com", "age": 25, "registration_date": "2023-01-15"}
        ]
        result = self.validator.validate(invalid_data)
        self.assertFalse(result['is_valid'])
        self.assertTrue(any("Name cannot be empty" in error for error in result['errors']))

    def test_invalid_date_format(self):
        """Test detection of invalid date format"""
        invalid_data = [
            {"name": "Bad Date", "email": "bad.date@example.com", "age": 28, "registration_date": "not_a_date"}
        ]
        result = self.validator.validate(invalid_data)
        self.assertFalse(result['is_valid'])
        self.assertTrue(any("Invalid date format" in error for error in result['errors']))

    def test_report_generation(self):
        """Test report generation"""
        data = [
            {"name": "Valid User", "email": "valid.user@example.com", "age": 28, "registration_date": "2023-01-15"},
            {"name": "Another Invalid", "email": "invalid-email", "age": -1, "registration_date": "2023-01-15"}
        ]
        result = self.validator.validate(data)
        report = self.validator.generate_report(result)
        self.assertIn("Valid Entries: 1", report)
        self.assertIn("Errors:", report)
        self.assertIn("Valid User", report)

    def test_future_registration_date(self):
        """Test detection of future registration date"""
        from datetime import datetime, timedelta
        future_date = (datetime.now() + timedelta(days=30)).strftime('%Y-%m-%d')
        invalid_data = [
            {"name": "Future User", "email": "future@example.com", "age": 25, "registration_date": future_date}
        ]
        result = self.validator.validate(invalid_data)
        self.assertFalse(result['is_valid'])
        self.assertTrue(any("Registration date cannot be in the future" in error for error in result['errors']))

if __name__ == '__main__':
    unittest.main()
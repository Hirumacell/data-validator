import json
import csv
from typing import Dict, List, Any, Optional
from src.utils import is_valid_email, is_valid_date, is_positive_integer, has_missing_values, check_logical_inconsistencies, parse_csv, parse_json
from src.report import ValidationReport

class DataValidator:
    def __init__(self, file_path: Optional[str] = None):
        self.file_path = file_path
        self.report = ValidationReport()
        self.required_fields = ['name', 'email', 'age', 'registration_date']
    
    def read_data(self) -> List[Dict[str, Any]]:
        """
        Read data from the file based on its extension
        """
        if not self.file_path:
            raise ValueError("No file path provided")
        
        if self.file_path.endswith('.json'):
            data = parse_json(self.file_path)
            return data.get('entries', data) if isinstance(data, dict) else data
        elif self.file_path.endswith('.csv'):
            return parse_csv(self.file_path)
        else:
            raise ValueError("Unsupported file format. Only JSON and CSV are supported.")
    
    def validate_format(self, entry: Dict[str, Any], index: int) -> List[str]:
        """
        Validate the format of individual fields in an entry
        """
        errors = []
        
        # Validate email format
        if 'email' in entry and entry['email']:
            if not is_valid_email(entry['email']):
                errors.append(f"Entry {index + 1}: Invalid email format '{entry['email']}'")
        
        # Validate date format
        if 'registration_date' in entry and entry['registration_date']:
            if not is_valid_date(entry['registration_date']):
                errors.append(f"Entry {index + 1}: Invalid date format '{entry['registration_date']}'")
        
        # Validate age format
        if 'age' in entry and entry['age'] is not None:
            try:
                age = int(entry['age'])
                if age < 0:
                    errors.append(f"Entry {index + 1}: Age cannot be negative ({age})")
                elif age > 150:
                    errors.append(f"Entry {index + 1}: Age seems unrealistic ({age})")
            except (ValueError, TypeError):
                errors.append(f"Entry {index + 1}: Age must be a valid number")
        
        return errors
    
    def check_missing_values(self, entry: Dict[str, Any], index: int) -> List[str]:
        """
        Check for missing required values in an entry
        """
        errors = []
        
        for field in self.required_fields:
            if field not in entry or entry[field] in (None, '', 0):
                if field == 'age' and entry.get(field) == 0:
                    continue  # Age 0 is valid
                if field == 'name' and entry.get(field) == '':
                    errors.append(f"Entry {index + 1}: Name cannot be empty")
                elif field not in entry or entry[field] in (None, ''):
                    errors.append(f"Entry {index + 1}: Missing required field '{field}'")
        
        return errors
    
    def check_logical_inconsistencies(self, entry: Dict[str, Any], index: int) -> List[str]:
        """
        Check for logical inconsistencies in an entry
        """
        errors = []
        
        # Check age consistency
        if 'age' in entry and entry['age'] is not None:
            try:
                age = int(entry['age'])
                if age < 0:
                    errors.append(f"Entry {index + 1}: Age cannot be negative")
            except (ValueError, TypeError):
                pass  # Already handled in format validation
        
        # Check registration date consistency (not in the future)
        if 'registration_date' in entry and entry['registration_date']:
            if is_valid_date(entry['registration_date']):
                from datetime import datetime
                reg_date = datetime.strptime(entry['registration_date'], '%Y-%m-%d')
                if reg_date > datetime.now():
                    errors.append(f"Entry {index + 1}: Registration date cannot be in the future")
        
        return errors
    
    def validate_entry(self, entry: Dict[str, Any], index: int) -> bool:
        """
        Validate a single entry and add errors to the report
        """
        errors = []
        
        # Check all validation criteria
        errors.extend(self.validate_format(entry, index))
        errors.extend(self.check_missing_values(entry, index))
        errors.extend(self.check_logical_inconsistencies(entry, index))
        
        # Add errors to report
        for error in errors:
            self.report.add_error(error)
        
        # If no errors, add as valid entry
        if not errors:
            self.report.add_valid_entry(entry)
            return True
        
        return False
    
    def validate(self, data: Optional[List[Dict[str, Any]]] = None) -> Dict[str, Any]:
        """
        Validate data entries and return validation result
        """
        if data is None:
            data = self.read_data()
        
        # Reset report
        self.report = ValidationReport()
        
        # Validate each entry
        for index, entry in enumerate(data):
            self.validate_entry(entry, index)
        
        return {
            'is_valid': len(self.report.errors) == 0,
            'errors': self.report.errors,
            'valid_entries': self.report.valid_entries,
            'summary': self.report.generate_report()['summary']
        }
    
    def validate_entries(self) -> Dict[str, Any]:
        """
        Main validation method
        """
        return self.validate()
    
    def generate_report(self, result: Optional[Dict[str, Any]] = None) -> str:
        """
        Generate a formatted validation report
        """
        if result is None:
            result = self.validate()
        
        report_lines = []
        report_lines.append("=" * 50)
        report_lines.append("DATA VALIDATION REPORT")
        report_lines.append("=" * 50)
        report_lines.append(f"Total Entries: {result['summary']['total_entries']}")
        report_lines.append(f"Valid Entries: {result['summary']['total_valid']}")
        report_lines.append(f"Errors: {result['summary']['total_errors']}")
        report_lines.append("")
        
        if result['errors']:
            report_lines.append("ERRORS DETECTED:")
            report_lines.append("-" * 20)
            for error in result['errors']:
                report_lines.append(f"❌ {error}")
            report_lines.append("")
        
        if result['valid_entries']:
            report_lines.append("VALID ENTRIES:")
            report_lines.append("-" * 20)
            for i, entry in enumerate(result['valid_entries'], 1):
                report_lines.append(f"✅ Entry {i}: {entry.get('name', 'Unknown')} ({entry.get('email', 'No email')})")
        
        report_lines.append("=" * 50)
        
        return "\n".join(report_lines)

    def validate_file(self, file_path: str) -> Dict[str, Any]:
        """
        Validate a specific file
        """
        self.file_path = file_path
        return self.validate()
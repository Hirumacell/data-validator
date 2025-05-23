class ValidationReport:
    def __init__(self):
        self.errors = []
        self.valid_entries = []
    
    def add_error(self, error_message):
        self.errors.append(error_message)
    
    def add_valid_entry(self, entry):
        self.valid_entries.append(entry)
    
    def generate_report(self):
        report = {
            "valid_entries": self.valid_entries,
            "errors": self.errors,
            "summary": {
                "total_entries": len(self.valid_entries) + len(self.errors),
                "total_errors": len(self.errors),
                "total_valid": len(self.valid_entries)
            }
        }
        return report
    
    def display_report(self):
        print("Validation Report:")
        print(f"Total Entries: {len(self.valid_entries) + len(self.errors)}")
        print(f"Valid Entries: {len(self.valid_entries)}")
        print(f"Errors: {len(self.errors)}")
        
        if self.errors:
            print("\nErrors Detected:")
            for error in self.errors:
                print(f"- {error}")
        
        if self.valid_entries:
            print("\nValid Entries:")
            for entry in self.valid_entries:
                print(f"- {entry}")
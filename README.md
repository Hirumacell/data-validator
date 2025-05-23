# Data Validator

## Overview
The Data Validator is a tool designed to validate data files (in formats such as CSV, JSON, etc.) to ensure that the data is correct, consistent, and complete before processing or storage. It checks for format adherence, missing values, and logical inconsistencies, generating a comprehensive validation report.

## Features
- Reads data files in various formats.
- Validates entries against expected formats (e.g., date, email).
- Checks for missing important values.
- Identifies logical inconsistencies (e.g., negative ages).
- Produces a detailed validation report listing errors and valid entries.

## Getting Started

### Prerequisites
Ensure you have Python installed on your machine. You can check your Python version by running:
```
python --version
```

### Installation
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd data-validator
   ```
3. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

### Usage
To use the Data Validator, you can run the `validator.py` script directly or integrate it into your application. The main class `DataValidator` provides methods for reading and validating data files.

### Running Tests
To run the automated tests, execute the following command:
```
pytest tests/
```

### Continuous Integration
You can also run the CI script to automate the testing process:
```
bash scripts/run_ci.sh
```

## File Structure
- `src/`: Contains the main source code for the validator.
  - `validator.py`: Main validation logic.
  - `report.py`: Report generation logic.
  - `utils.py`: Utility functions for data handling.
- `tests/`: Contains unit tests for the validator.
  - `test_validator.py`: Tests for the `DataValidator` class.
  - `test_data/`: Sample data for testing.
    - `valid_data.json`: Valid data entries.
    - `invalid_data.json`: Invalid data entries with errors.
- `scripts/`: Contains automation scripts.
  - `run_ci.sh`: Script to run tests and generate reports.
- `requirements.txt`: Lists project dependencies.
- `README.md`: Documentation for the project.
- `.gitignore`: Specifies files to ignore in version control.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any suggestions or improvements.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
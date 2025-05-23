def is_valid_email(email):
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def is_valid_date(date_string):
    from datetime import datetime
    try:
        datetime.strptime(date_string, '%Y-%m-%d')
        return True
    except ValueError:
        return False

def is_positive_integer(value):
    try:
        return int(value) > 0
    except (ValueError, TypeError):
        return False

def has_missing_values(data_entry, required_fields):
    return any(field not in data_entry or data_entry[field] in (None, '') for field in required_fields)

def check_logical_inconsistencies(data_entry):
    if 'age' in data_entry and not is_positive_integer(data_entry['age']):
        return True
    return False

def parse_csv(file_path):
    import csv
    with open(file_path, mode='r') as file:
        reader = csv.DictReader(file)
        return [row for row in reader]

def parse_json(file_path):
    import json
    with open(file_path, 'r') as file:
        return json.load(file)
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Start CI simulation
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}       Simulated CI Pipeline            ${NC}"
echo -e "${YELLOW}========================================${NC}"

# Step 0: Check if Python and pip are installed
echo -e "${YELLOW}Checking if Python and pip are installed...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3 is not installed. Please install it and try again.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Python3 is installed: $(python3 --version)${NC}"
fi

if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}✗ pip3 is not installed. Please install it and try again.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ pip3 is installed: $(pip3 --version)${NC}"
fi

# Step 1: Create and activate virtual environment
echo -e "${YELLOW}Setting up virtual environment...${NC}"
if [ -d "venv" ]; then
    echo -e "${YELLOW}Virtual environment already exists. Skipping creation.${NC}"
else
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to create virtual environment.${NC}"
        exit 1
    fi
fi
source venv/bin/activate

# Step 2: Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
pip install -r requirements.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to install dependencies.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Dependencies installed successfully${NC}"
fi

# Step 3: Run tests with coverage
echo -e "${YELLOW}Running tests with coverage...${NC}"
pytest tests/ --cov=src --cov-report=term --cov-report=html:coverage_html --cov-report=xml:coverage.xml > reports/test_report.txt 2>&1
TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed successfully${NC}"
else
    echo -e "${RED}✗ Some tests failed. Check the report in 'reports/test_report.txt'${NC}"
fi

# Step 4: Generate coverage report
echo -e "${YELLOW}Generating coverage report...${NC}"
if [ -f "coverage.xml" ]; then
    COVERAGE=$(grep -oP 'line-rate="\K[0-9.]+' coverage.xml | awk '{print $1 * 100}')
    echo -e "${GREEN}✓ Coverage report generated: ${COVERAGE}%${NC}"
    echo "Coverage: ${COVERAGE}%" > reports/coverage_summary.txt
else
    echo -e "${RED}✗ Failed to generate coverage report${NC}"
    exit 1
fi

# Step 5: Display summary
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}           CI Pipeline Summary          ${NC}"
echo -e "${YELLOW}========================================${NC}"
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
else
    echo -e "${RED}✗ Some tests failed${NC}"
fi
echo -e "${GREEN}✓ Coverage: ${COVERAGE}%${NC}"
echo -e "${YELLOW}Reports generated:${NC}"
echo "  - Test report: reports/test_report.txt"
echo "  - Coverage report (HTML): coverage_html/index.html"
echo "  - Coverage summary: reports/coverage_summary.txt"

# Step 6: Option to clean the venv
if [ "$1" == "--clean" ]; then
    echo -e "${YELLOW}Cleaning existing virtual environment...${NC}"
    rm -rf venv
fi

# Exit with the appropriate code
exit $TEST_EXIT_CODE
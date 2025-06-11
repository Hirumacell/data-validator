# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sans couleur

# Début de la simulation CI
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}      Simulation de la pipeline CI      ${NC}"
echo -e "${YELLOW}========================================${NC}"

# Étape 0 : Vérification de Python et pip
echo -e "${YELLOW}Vérification de l'installation de Python3 et pip3...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3 n'est pas installé. Veuillez l'installer puis réessayer.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Python3 est installé : $(python3 --version)${NC}"
fi

if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}✗ pip3 n'est pas installé. Veuillez l'installer puis réessayer.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ pip3 est installé : $(pip3 --version)${NC}"
fi

# Étape 1 : Création et activation de l'environnement virtuel
echo -e "${YELLOW}Création de l'environnement virtuel...${NC}"
if [ -d "venv" ]; then
    echo -e "${YELLOW}L'environnement virtuel existe déjà. Création ignorée.${NC}"
else
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Échec de la création de l'environnement virtuel.${NC}"
        exit 1
    fi
fi
source venv/bin/activate

# Étape 2 : Installation des dépendances
echo -e "${YELLOW}Installation des dépendances...${NC}"
pip install -r requirements.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Échec de l'installation des dépendances.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Dépendances installées avec succès${NC}"
fi

# Étape 3 : Lancement des tests avec Couverture
echo -e "${YELLOW}Exécution des tests avec Couverture...${NC}"
pytest tests/ --cov=src --cov-report=term --cov-report=html:coverage_html --cov-report=xml:coverage.xml > reports/test_report.txt 2>&1
CODE_SORTIE_TEST=$?

if [ $CODE_SORTIE_TEST -eq 0 ]; then
    echo -e "${GREEN}✓ Tous les tests ont réussi${NC}"
else
    echo -e "${RED}✗ Certains tests ont échoué. Consultez le rapport : 'reports/test_report.txt'${NC}"
fi

# Étape 4 : Génération du rapport de Couverture
echo -e "${YELLOW}Génération du rapport de Couverture...${NC}"
if [ -f "coverage.xml" ]; then
    Couverture=$(grep -oP 'line-rate="\K[0-9.]+' coverage.xml | awk '{print $1 * 100}')
    echo -e "${GREEN}✓ Rapport de Couverture généré : ${Couverture}%${NC}"
    echo "Couverture : ${Couverture}%" > reports/coverage_summary.txt
else
    echo -e "${RED}✗ Échec de la génération du rapport de Couverture${NC}"
    exit 1
fi

# Étape 5 : Affichage du résumé
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}        Résumé de la pipeline CI        ${NC}"
echo -e "${YELLOW}========================================${NC}"
if [ $CODE_SORTIE_TEST -eq 0 ]; then
    echo -e "${GREEN}✓ Tous les tests sont passés avec succès${NC}"
else
    echo -e "${RED}✗ Des tests ont échoué${NC}"
fi
echo -e "${GREEN}✓ Couverture : ${Couverture}%${NC}"
echo -e "${YELLOW}Rapports générés :${NC}"
echo "  - Rapport de tests : reports/test_report.txt"
echo "  - Rapport de Couverture (HTML) : coverage_html/index.html"
echo "  - Résumé de Couverture : reports/coverage_summary.txt"

# Étape 6 : Option de nettoyage de l'environnement virtuel
if [ "$1" == "--clean" ]; then
    echo -e "${YELLOW}Suppression de l'environnement virtuel existant...${NC}"
    rm -rf venv
fi

# Sortie avec le code approprié
exit $CODE_SORTIE_TEST

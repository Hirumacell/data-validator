#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}    Correction Environnement Virtuel    ${NC}"
echo -e "${YELLOW}========================================${NC}"

# 1. Nettoyer l'ancien environnement virtuel
echo -e "${YELLOW}1. Nettoyage de l'ancien environnement virtuel...${NC}"
if [ -d "venv" ]; then
    echo "Suppression du venv existant..."
    rm -rf venv
    echo -e "${GREEN}✓ Ancien venv supprimé${NC}"
fi

# 2. Créer un nouvel environnement virtuel
echo -e "${YELLOW}2. Création d'un nouvel environnement virtuel...${NC}"
python3 -m venv venv
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Nouvel environnement virtuel créé${NC}"
else
    echo -e "${RED}✗ Échec de la création de l'environnement virtuel${NC}"
    exit 1
fi

# 3. Créer requirements.txt si inexistant
if [ ! -f "requirements.txt" ]; then
    echo -e "${YELLOW}3. Création d'un requirements.txt basique...${NC}"
    cat > requirements.txt << 'EOF'
# Requirements for data validation project
pytest>=7.0.0
pytest-cov>=4.0.0
pandas>=1.5.0
numpy>=1.21.0
EOF
    echo -e "${GREEN}✓ requirements.txt créé${NC}"
else
    echo -e "${GREEN}✓ requirements.txt existe déjà${NC}"
fi

# 4. Activer et tester l'environnement virtuel
echo -e "${YELLOW}4. Test de l'environnement virtuel...${NC}"
source venv/bin/activate

if [ "$VIRTUAL_ENV" != "" ]; then
    echo -e "${GREEN}✓ Environnement virtuel activé: $VIRTUAL_ENV${NC}"
    
    # 5. Mettre à jour pip
    echo -e "${YELLOW}5. Mise à jour de pip...${NC}"
    $VIRTUAL_ENV/bin/python -m pip install --upgrade pip
    
    # 6. Installer les dépendances
    echo -e "${YELLOW}6. Installation des dépendances...${NC}"
    $VIRTUAL_ENV/bin/pip install -r requirements.txt
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Dépendances installées avec succès${NC}"
        
        # 7. Vérifier l'installation
        echo -e "${YELLOW}7. Vérification de l'installation...${NC}"
        echo "Packages installés:"
        $VIRTUAL_ENV/bin/pip list
        
        # Test de pytest
        if $VIRTUAL_ENV/bin/python -c "import pytest" 2>/dev/null; then
            echo -e "${GREEN}✓ pytest installé et fonctionnel${NC}"
        else
            echo -e "${RED}✗ Problème avec pytest${NC}"
        fi
        
    else
        echo -e "${RED}✗ Échec de l'installation des dépendances${NC}"
        exit 1
    fi
    
else
    echo -e "${RED}✗ Échec de l'activation de l'environnement virtuel${NC}"
    exit 1
fi

# 8. Créer la structure de base si nécessaire
echo -e "${YELLOW}8. Vérification de la structure du projet...${NC}"

# Créer le dossier reports
if [ ! -d "reports" ]; then
    mkdir -p reports
    echo -e "${GREEN}✓ Dossier reports créé${NC}"
fi

# Créer le dossier tests avec un test basique
if [ ! -d "tests" ]; then
    mkdir -p tests
    cat > tests/test_basic.py << 'EOF'
"""Tests basiques pour vérifier que le framework fonctionne"""

def test_basic():
    """Test basique qui doit toujours passer"""
    assert True

def test_python_version():
    """Vérifier que Python >= 3.6"""
    import sys
    assert sys.version_info >= (3, 6)

def test_imports():
    """Vérifier que les imports de base fonctionnent"""
    import json
    import csv
    import re
    from datetime import datetime
    assert True
EOF
    echo -e "${GREEN}✓ Structure de tests créée${NC}"
fi

# 9. Test final
echo -e "${YELLOW}9. Test final du pipeline...${NC}"
$VIRTUAL_ENV/bin/pytest tests/ -v
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Tests passent avec succès${NC}"
else
    echo -e "${YELLOW}⚠ Certains tests ont échoué, mais l'environnement est prêt${NC}"
fi

echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}           ENVIRONNEMENT PRÊT           ${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}Vous pouvez maintenant exécuter:${NC}"
echo "  bash ./scripts/run_ci.sh"
echo ""
echo -e "${YELLOW}Pour activer manuellement l'environnement:${NC}"
echo "  source venv/bin/activate"
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}        Diagnostic du Problème CI       ${NC}"
echo -e "${YELLOW}========================================${NC}"

# 1. Vérifier la structure du projet
echo -e "${BLUE}1. Structure du projet:${NC}"
echo "Répertoire courant: $(pwd)"
echo "Contenu:"
ls -la

# 2. Vérifier requirements.txt
echo -e "\n${BLUE}2. Vérification de requirements.txt:${NC}"
if [ -f "requirements.txt" ]; then
    echo -e "${GREEN}✓ requirements.txt trouvé${NC}"
    echo "Contenu:"
    cat requirements.txt
else
    echo -e "${RED}✗ requirements.txt manquant${NC}"
fi

# 3. Vérifier l'environnement virtuel
echo -e "\n${BLUE}3. Vérification de l'environnement virtuel:${NC}"
if [ -d "venv" ]; then
    echo -e "${GREEN}✓ Dossier venv existe${NC}"
    if [ -f "venv/bin/activate" ]; then
        echo -e "${GREEN}✓ Script d'activation présent${NC}"
    else
        echo -e "${RED}✗ Script d'activation manquant${NC}"
    fi
    
    # Tenter d'activer et tester
    echo "Test d'activation:"
    source venv/bin/activate
    if [ "$VIRTUAL_ENV" != "" ]; then
        echo -e "${GREEN}✓ Activation réussie: $VIRTUAL_ENV${NC}"
        echo "Python utilisé: $(which python)"
        echo "Pip utilisé: $(which pip)"
        
        # Tester une installation simple
        echo "Test d'installation d'un package simple:"
        pip install --dry-run pytest 2>&1 | head -5
        
    else
        echo -e "${RED}✗ Échec de l'activation${NC}"
    fi
else
    echo -e "${RED}✗ Dossier venv manquant${NC}"
fi

# 4. Vérifier les permissions
echo -e "\n${BLUE}4. Vérification des permissions:${NC}"
echo "Permissions du répertoire courant:"
ls -ld .
if [ -d "venv" ]; then
    echo "Permissions du répertoire venv:"
    ls -ld venv
fi

# 5. Vérifier l'espace disque
echo -e "\n${BLUE}5. Vérification de l'espace disque:${NC}"
df -h .

# 6. Vérifier la connectivité réseau (pour pip)
echo -e "\n${BLUE}6. Test de connectivité réseau:${NC}"
if command -v curl &> /dev/null; then
    curl -s --connect-timeout 5 https://pypi.org > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Connexion à PyPI OK${NC}"
    else
        echo -e "${RED}✗ Problème de connexion à PyPI${NC}"
    fi
else
    echo "curl non disponible, test de connectivité ignoré"
fi

# 7. Essai manuel d'installation
echo -e "\n${BLUE}7. Test d'installation manuelle:${NC}"
if [ -d "venv" ]; then
    source venv/bin/activate 2>/dev/null
    echo "Tentative d'installation de pytest seul:"
    pip install pytest --verbose 2>&1 | head -10
fi

echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}         Fin du diagnostic               ${NC}"
echo -e "${YELLOW}========================================${NC}"
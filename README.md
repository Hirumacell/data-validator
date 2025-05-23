# Data Validator

## Overview
Vous êtes chargé(e) de développer un petit outil capable de valider un fichier de données (au format texte, CSV, JSON, etc.). Ces données proviennent d’un formulaire, d’une base ou d’un fichier externe. Avant de les traiter ou de les enregistrer, votre outil doit s’assurer que les valeurs sont correctes, cohérentes et complètes.

## Fonctionnalités
- Lit les fichiers de données.
- Valide les entrées selon des formats attendus (par exemple : date, email).
- Vérifie l'absence de valeurs importantes manquantes.
- Identifie les incohérences logiques (par exemple : âges négatifs).
- Produit un rapport détaillé de validation listant les erreurs et les entrées valides.

## Prise en main

### Prérequis
Assurez-vous que Python est installé sur votre machine. Vous pouvez vérifier la version de Python en exécutant la commande suivante :
```
python --version
```

### Installation
1. Clonez le dépôt :
   ```
   git clone <repository-url>
   ```
2. Accédez au répertoire du projet :
   ```
   cd data-validator
   ```
3. Installez les dépendances nécessaires :
   ```
   pip install -r requirements.txt
   ```

### Utilisation
Pour utiliser le Validateur de Données, vous pouvez exécuter directement le script `validator.py` ou l'intégrer dans votre application. La classe principale `DataValidator` fournit des méthodes pour lire et valider les fichiers de données.

### Exécution des Tests
Pour exécuter les tests automatisés, utilisez la commande suivante :
```
pytest tests/
```

## Pipeline CI Locale
- Vérifie que Python et pip sont installés.
- Met à jour les paquets système.
- Configure un environnement virtuel.
- Installe les dépendances.
- Exécute les tests avec `pytest` et génère un rapport de couverture.
- Affiche un résumé des résultats.

### Exécution de la pipeline locale
1. Donnez les permissions d'exécution au script (si ce n'est pas déjà fait) :
   ```
   chmod +x scripts/run_ci.sh
   ```
2. Exécutez le script :
   ```
   bash ./scripts/run_ci.sh
   ```
3. Si vous souhaitez nettoyer l'environnement virtuel avant de l'exécuter :
   ```
   bash ./scripts/run_ci.sh --clean
   ```  

### Résultats générés
- Rapport de tests : `reports/test_report.txt`
- Rapport de couverture HTML : `coverage_html/index.html`
- Résumé de couverture : `reports/coverage_summary.txt`

## Structure des fichiers
- `src/` : Contient le code source principal du validateur.
	- `validator.py` : Logique principale de validation.
	- `utils.py` : Fonctions utilitaires pour la gestion des données.
	- `report.py` : Génération de rapports.
- `tests/` : Contient les tests unitaires pour le validateur.
	- `test_validator.py` : Tests pour la classe DataValidator.
	- `test_data/` : Données d'exemple pour les tests.
		- `valid_data.json` : Entrées de données valides.
		- `invalid_data.json` : Entrées de données invalides avec des erreurs.
- `scripts/` : Contient les scripts d'automatisation.
	- `run_ci.sh` : Script pour exécuter la pipeline CI locale.
- `requirements.txt` : Liste des dépendances du projet.
- `README.md` : Documentation du projet.
- `.gitignore` : Spécifie les fichiers à ignorer dans le contrôle de version.

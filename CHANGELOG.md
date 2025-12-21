# Historique des versions

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### Ajouté

- Support complet pour IBM i TOBI (Tool for Building ILE)
  - Configuration `iproj.json` avec métadonnées du projet
  - `Rules.mk` avec cibles Make automatiques (all, service, test, clean)
  - Documentation complète dans `BUILD_WITH_TOBI.md`
  - Script de validation `validate_tobi.sh`
  - Exemple de workflow GitHub Actions (`.github/workflows/build-example.yml.disabled`)
- Amélioration du `.gitignore` pour inclure les artefacts TOBI
- Mise à jour du README avec les méthodes de compilation TOBI
- Mise à jour des instructions pour agents IA avec informations TOBI

### Modifié

- Réorganisation de la documentation de compilation dans README.md
- Instructions Copilot enrichies avec workflows TOBI
- Priorité donnée à TOBI comme méthode de compilation recommandée

## [1.0.0] - 2025-12-20

### Ajouté

- Module de service de journalisation principal (`LOGGER.SQLRPGLE`)
- Cinq niveaux de log : DEBUG, INFO, WARNING, ERROR, FATAL
- Fonctions de base :
  - `Logger_Init()` - Initialisation du service
  - `Logger_Term()` - Terminaison du service
  - `Logger_Debug()` - Messages de débogage
  - `Logger_Info()` - Messages d'information
  - `Logger_Warning()` - Messages d'avertissement
  - `Logger_Error()` - Messages d'erreur
  - `Logger_Fatal()` - Messages d'erreur fatale
  - `Logger_SetLevel()` - Configuration du niveau de log
  - `Logger_GetLevel()` - Récupération du niveau de log actuel
- Programme de service (*SRVPGM) avec exports définis dans `LOGGER.BND`
- Support thread-safe avec `thread(*serialize)`
- Horodatage automatique des messages au format ISO
- Programme de test complet (`TESTLOGGER.SQLRPGLE`)
- Exemple simple d'utilisation (`EXAMPLE.SQLRPGLE`)
- Fichier de copie pour l'API (`LOGGERAPI.RPGLEINC`)
- Scripts de compilation pour PASE (`build.sh`, `build_test.sh`)
- Programme CL de compilation (`CRTLOGGER.CLLE`)
- Documentation complète en français (README.md)
- Guide de contribution (CONTRIBUTING.md)
- Licence Apache 2.0

### Fonctionnalités

- Filtrage des messages par niveau de log
- Écriture dans stdout via `Qp0zLprintf`
- Support des caractères spéciaux français
- Configuration dynamique du niveau de log
- Documentation complète en français

### Notes techniques

- Testé sur IBM i 7.3+
- Requiert ILE RPG avec support SQL
- Utilise le format libre RPG (`**FREE`)
- Groupe d'activation : `*CALLER`
- Modèle de stockage : `*INHERIT`

[Non publié]: https://github.com/IBMiservices/logfori/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/IBMiservices/logfori/releases/tag/v1.0.0

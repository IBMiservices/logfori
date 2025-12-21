# Historique des versions

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### Modifié

- **BREAKING**: Noms de procédures en PascalCase sans underscore
  - `Logger_Init` → `LoggerInit`
  - `Logger_Term` → `LoggerTerm`
  - `Logger_Debug` → `LoggerDebug`
  - `Logger_Info` → `LoggerInfo`
  - `Logger_Warning` → `LoggerWarning`
  - `Logger_Error` → `LoggerError`
  - `Logger_Fatal` → `LoggerFatal`
  - `Logger_SetLevel` → `LoggerSetLevel`
  - `Logger_GetLevel` → `LoggerGetLevel`
- **BREAKING**: TOBI est maintenant la méthode de build officielle et unique
  - Suppression des scripts shell `build.sh` et `build_test.sh`
  - Configuration complète via `iproj.json` et `Rules.mk`
  - Cibles TOBI : `compile`, `test`, `example`, `clean`
- Documentation complètement révisée pour TOBI
  - README.md simplifié avec focus sur TOBI
  - CONTRIBUTING.md mis à jour avec commandes TOBI
  - Instructions Copilot (.github/copilot-instructions.md) alignées sur TOBI
- Programme d'exemple renommé : `EXAMPLE.SQLRPGLE` → `EXAMPLE.PGM.SQLRPGLE`
- Programme de test renommé : `TESTLOGGER.SQLRPGLE` → `TESTLOGGER.PGM.RPGLE`
- Utilisation du fichier de copie `LOGGERAPI.RPGLEINC` dans les exemples
- Binding directory renommé : `LOGGER` → `SERVICES`

### Ajouté

- Fichier de copie `qcpysrc/LOGGERAPI.RPGLEINC` pour faciliter l'utilisation de l'API
- `Rules.mk` dans tous les répertoires sources (qrpglesrc, qsrvsrc, qbndsrc)
- Configuration `iproj.json` avec métadonnées du projet et chemins d'inclusion

## [1.0.0] - 2025-12-20

### Ajouté

- Module de service de journalisation principal (`LOGGER.SQLRPGLE`)
- Cinq niveaux de log : DEBUG, INFO, WARNING, ERROR, FATAL
- Fonctions de base :
  - `LoggerInit()` - Initialisation du service
  - `LoggerTerm()` - Terminaison du service
  - `LoggerDebug()` - Messages de débogage
  - `LoggerInfo()` - Messages d'information
  - `LoggerWarning()` - Messages d'avertissement
  - `LoggerError()` - Messages d'erreur
  - `LoggerFatal()` - Messages d'erreur fatale
  - `LoggerSetLevel()` - Configuration du niveau de log
  - `LoggerGetLevel()` - Récupération du niveau de log actuel
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
- Écriture dans le joblog via `Qp0zLprintf`
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

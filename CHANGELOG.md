# Historique des versions

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

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
  - `LoggerInitFromJobLog()` - Initialisation avec synchronisation automatique du niveau LOG du job
- Programme de service (*SRVPGM) avec exports définis dans `LOGGER.BND`
- Support thread-safe avec `thread(*serialize)`
- Horodatage automatique des messages au format ISO
- Programme de test complet (`TESTLOGGER.PGM.RPGLE`)
- Exemple simple d'utilisation (`EXAMPLE.PGM.SQLRPGLE`)
- Fichier de copie pour l'API (`qcpysrc/LOGGERAPI.RPGLEINC`)
- Système de build TOBI avec `Rules.mk` et `iproj.json`
- Binding directory `SERVICES.BNDDIR` pour faciliter l'usage
- Documentation complète en français (README.md)
- Guide de contribution (CONTRIBUTING.md)
- Instructions pour GitHub Copilot
- Licence Apache 2.0

### Fonctionnalités

- Filtrage des messages par niveau de log
- Écriture dans le joblog via `Qp0zLprintf`
- Synchronisation automatique avec le paramètre LOG du job IBM i
- Support des caractères spéciaux français
- Configuration dynamique du niveau de log
- Documentation ILEDocs complète

### Notes techniques

- Testé sur IBM i 7.5+
- Requiert ILE RPG avec support SQL
- Utilise le format libre RPG (`**FREE`)
- Module nomain avec procédures exportées
- Compilation via TOBI (makei)

[Non publié]: https://github.com/IBMiservices/logfori/compare/v1.0.0...HEAD

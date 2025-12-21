# LOGFORI - Service de Journalisation pour IBM i

Service de journalisation (logging) professionnel pour IBM i, fourni sous forme de programme de service (*SRVPGM).

## 📋 Description

LOGFORI est un service de journalisation léger et efficace pour les applications IBM i écrites en ILE RPG. Il offre :

- ✅ Plusieurs niveaux de journalisation (DEBUG, INFO, WARNING, ERROR, FATAL)
- ✅ Configuration dynamique du niveau de log
- ✅ Messages horodatés automatiquement
- ✅ Programme de service réutilisable
- ✅ Thread-safe avec `thread(*serialize)`
- ✅ Documentation complète en français

## 🚀 Installation

### Prérequis

- IBM i 7.5 ou supérieur
- Compilateur ILE RPG avec support SQL
- [IBM i TOBI](https://github.com/IBM/ibmi-tobi) installé (gestionnaire de build)
- Accès à QSYS pour créer des objets

### Compilation rapide

```bash
# Depuis le répertoire du projet
makei compile

# Compiler et tester
makei test
```

### Options de compilation

#### Bibliothèque personnalisée

```bash
# Spécifier une bibliothèque cible (par défaut : &CURLIB)
makei OBJLIB=MYLIB compile
```

#### Cibles disponibles

- `makei compile` - Compile le service LOGGER (*SRVPGM) et le BNDDIR
- `makei test` - Compile le programme de test (TESTLOGGER.PGM)
- `makei example` - Compile le programme d'exemple
- `makei clean` - Nettoie les objets compilés

### Pour en savoir plus

Consultez la [documentation TOBI](https://ibm.github.io/ibmi-tobi) pour des informations détaillées sur le système de build.

## 📖 Utilisation

### Exemple de base

```rpgle
**FREE

ctl-opt dftactgrp(*no) actgrp(*new) bnddir('SERVICES');

// Importer l'API LOGGER (prototypes et constantes)
/copy qcpysrc,loggerapi

// Initialiser le service
LoggerInit();

// Écrire un message
LoggerInfo('Application démarrée avec succès');

// Terminer le service
LoggerTerm();

*inlr = *on;
```

Voir [qrpglesrc/EXAMPLE.PGM.SQLRPGLE](qrpglesrc/EXAMPLE.PGM.SQLRPGLE) pour un exemple complet.

### Niveaux de journalisation

```rpgle
**FREE

ctl-opt dftactgrp(*no) actgrp(*new) bnddir('SERVICES');

/copy qcpysrc,loggerapi  // Importe les constantes et prototypes

LoggerInit();

// Tous les niveaux disponibles
LoggerDebug('Détails de débogage');
LoggerInfo('Information générale');
LoggerWarning('Attention, situation inhabituelle');
LoggerError('Erreur récupérable');
LoggerFatal('Erreur fatale, arrêt nécessaire');

// Changer le niveau de log (seuls ERROR et FATAL seront affichés)
LoggerSetLevel(LOG_LEVEL_ERROR);

LoggerTerm();
```

### Programme de test complet

Un programme de test complet est fourni dans [qrpglesrc/TESTLOGGER.PGM.RPGLE](qrpglesrc/TESTLOGGER.PGM.RPGLE). Pour le compiler et l'exécuter :

```bash
# Compiler avec TOBI
makei test

# Exécuter le programme de test
system "CALL &CURLIB/TESTLOGGER"
```

La commande `makei test` compile le service LOGGER et le programme de test. Vous devez ensuite exécuter manuellement le programme.

## 🔧 API de référence

### Procédures d'initialisation

#### `LoggerInit()`
Initialise le service de journalisation. Doit être appelé avant toute autre fonction.

#### `LoggerTerm()`
Termine le service de journalisation proprement.

### Procédures de journalisation

#### `LoggerDebug(message)`
Enregistre un message de débogage (niveau 0).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

#### `LoggerInfo(message)`
Enregistre un message d'information (niveau 1).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

#### `LoggerWarning(message)`
Enregistre un message d'avertissement (niveau 2).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

#### `LoggerError(message)`
Enregistre un message d'erreur (niveau 3).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

#### `LoggerFatal(message)`
Enregistre un message d'erreur fatale (niveau 4).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

### Procédures de configuration

#### `LoggerSetLevel(level)`
Définit le niveau minimum de journalisation.
- **Paramètre** : `level` - Niveau (0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=FATAL)

#### `LoggerGetLevel()`
Retourne le niveau de journalisation actuel.
- **Retour** : Niveau actuel (INT 10)

## 📁 Structure du projet

```
logfori/
├── qrpglesrc/              # Sources RPG
│   ├── LOGGER.SQLRPGLE     # Module principal du service de log
│   ├── TESTLOGGER.PGM.RPGLE # Programme de test
│   ├── EXAMPLE.PGM.SQLRPGLE # Programme d'exemple
│   └── Rules.mk            # Règles de build TOBI
├── qsrvsrc/                # Sources service program
│   ├── LOGGER.BND          # Définition des exports
│   └── Rules.mk            # Règles de build TOBI
├── qbndsrc/                # Binding directories
│   ├── SERVICES.BNDDIR     # Définition du BNDDIR
│   └── Rules.mk            # Règles de build TOBI
├── qcpysrc/                # Fichiers de copie
│   └── LOGGERAPI.RPGLEINC  # API publique (prototypes et constantes)
├── iproj.json              # Configuration du projet TOBI
├── Rules.mk                # Règles de build racine
├── README.md               # Documentation principale
├── CONTRIBUTING.md         # Guide de contribution
├── CHANGELOG.md            # Historique des versions
└── LICENSE                 # Licence Apache 2.0
```

## 🎯 Fonctionnalités avancées

### Filtrage par niveau

Le système de niveaux permet de filtrer les messages :

```rpgle
// Niveau INFO : affiche INFO, WARNING, ERROR, FATAL (pas DEBUG)
LoggerSetLevel(LOG_LEVEL_INFO);

// Niveau WARNING : affiche seulement WARNING, ERROR, FATAL
LoggerSetLevel(LOG_LEVEL_WARNING);

// Niveau ERROR : affiche seulement ERROR et FATAL
LoggerSetLevel(LOG_LEVEL_ERROR);
```

### Thread Safety

Le module est compilé avec `thread(*serialize)`, ce qui garantit que les écritures dans le journal sont sérialisées et ne se chevauchent pas dans un environnement multi-thread.

### Format des messages

Les messages sont automatiquement formatés avec :
- Horodatage (timestamp ISO)
- Niveau de log entre crochets
- Message utilisateur

Exemple :
```
2025-12-20-15.30.45.123456 [INFO] Application démarrée avec succès
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche pour votre fonctionnalité
3. Committer vos changements
4. Pousser vers la branche
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence Apache 2.0. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Auteurs

- IBM i Services

## 🔗 Ressources

- [IBM i TOBI - Documentation](https://ibm.github.io/ibmi-tobi) - Système de build utilisé
- [IBM i TOBI - GitHub](https://github.com/IBM/ibmi-tobi) - Code source et issues
- [IBM i Documentation](https://www.ibm.com/docs/en/i)
- [ILE RPG Reference](https://www.ibm.com/docs/en/i/7.5?topic=languages-ile-rpg)
- [Service Programs](https://www.ibm.com/docs/en/i/7.5?topic=programs-service)

## ⚠️ Notes

- Le service écrit actuellement dans le joblog via `Qp0zLprintf`
- Pour écrire dans QSYSOPR, décommenter la section correspondante dans `writeLog()`
- Testé sur IBM i 7.3+
- Supporte les caractères Unicode et les caractères spéciaux français
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

- IBM i 7.3 ou supérieur
- Compilateur ILE RPG avec support SQL
- Accès à QSYS pour créer des objets

### Compilation

#### Méthode 1 : Avec IBM i TOBI (recommandé)

```bash
# Depuis le répertoire du projet
makei all

# Ou avec une bibliothèque spécifique
makei OBJLIB=MYLIB all

# Compiler et tester
makei test
```

Pour plus de détails, voir [BUILD_WITH_TOBI.md](BUILD_WITH_TOBI.md).

#### Méthode 2 : Avec script shell

1. Transférer les fichiers source sur IBM i dans un répertoire IFS (par exemple `/home/myuser/logfori`)

2. Compiler le programme de service :

```bash
./build.sh MYLIB
```

#### Méthode 3 : Avec CL

#### Méthode 3 : Avec CL

```
CLLE SRCSTMF('/home/myuser/logfori/qcmdsrc/CRTLOGGER.CLLE')
CALL PGM(CRTLOGGER) PARM('MYLIB')
```

#### Méthode 4 : Manuellement

```
CRTSQLRPGI OBJ(MYLIB/LOGGER) +
          SRCSTMF('/home/myuser/logfori/qrpglesrc/LOGGER.SQLRPGLE') +
          OBJTYPE(*MODULE) +
          DBGVIEW(*SOURCE) +
          REPLACE(*YES) +
          COMMIT(*NONE)

CRTSRVPGM SRVPGM(MYLIB/LOGGER) +
          MODULE(MYLIB/LOGGER) +
          EXPORT(*SRCFILE) +
          SRCSTMF('/home/myuser/logfori/qsrvsrc/LOGGER.BND') +
          REPLACE(*YES) +
          TEXT('Service de journalisation')
```

3. Créer un répertoire de liaison (optionnel mais recommandé) :

```
CRTBNDDIR BNDDIR(MYLIB/LOGGER)
ADDBNDDIRE BNDDIR(MYLIB/LOGGER) OBJ((MYLIB/LOGGER *SRVPGM))
```

## 📖 Utilisation

### Exemple de base

```rpgle
**FREE

ctl-opt dftactgrp(*no) actgrp(*new) bnddir('MYLIB/LOGGER');

// Prototypes
dcl-pr Logger_Init extproc('Logger_Init') end-pr;
dcl-pr Logger_Info extproc('Logger_Info') varchar(512) const;
  message varchar(512) const;
end-pr;
dcl-pr Logger_Term extproc('Logger_Term') end-pr;

// Initialiser le service
Logger_Init();

// Écrire un message
Logger_Info('Application démarrée avec succès');

// Terminer le service
Logger_Term();

*inlr = *on;
```

### Niveaux de journalisation

```rpgle
// Déclaration des constantes
dcl-c LOG_LEVEL_DEBUG 0;
dcl-c LOG_LEVEL_INFO 1;
dcl-c LOG_LEVEL_WARNING 2;
dcl-c LOG_LEVEL_ERROR 3;
dcl-c LOG_LEVEL_FATAL 4;

// Prototypes supplémentaires
dcl-pr Logger_Debug extproc('Logger_Debug') varchar(512) const;
  message varchar(512) const;
end-pr;
dcl-pr Logger_Warning extproc('Logger_Warning') varchar(512) const;
  message varchar(512) const;
end-pr;
dcl-pr Logger_Error extproc('Logger_Error') varchar(512) const;
  message varchar(512) const;
end-pr;
dcl-pr Logger_Fatal extproc('Logger_Fatal') varchar(512) const;
  message varchar(512) const;
end-pr;
dcl-pr Logger_SetLevel extproc('Logger_SetLevel');
  level int(10) const;
end-pr;

// Utilisation
Logger_Init();

Logger_Debug('Détails de débogage');
Logger_Info('Information générale');
Logger_Warning('Attention, situation inhabituelle');
Logger_Error('Erreur récupérable');
Logger_Fatal('Erreur fatale, arrêt nécessaire');

// Changer le niveau de log (seuls ERROR et FATAL seront affichés)
Logger_SetLevel(LOG_LEVEL_ERROR);

Logger_Term();
```

### Programme de test complet

Un programme de test complet est fourni dans `qrpglesrc/TESTLOGGER.SQLRPGLE`. Pour le compiler et l'exécuter :

```
CRTSQLRPGI OBJ(MYLIB/TESTLOGGER) +
          SRCSTMF('/home/myuser/logfori/qrpglesrc/TESTLOGGER.SQLRPGLE') +
          OBJTYPE(*PGM) +
          DBGVIEW(*SOURCE) +
          REPLACE(*YES) +
          COMMIT(*NONE)

CALL MYLIB/TESTLOGGER
```

## 🔧 API de référence

### Procédures d'initialisation

#### `Logger_Init()`
Initialise le service de journalisation. Doit être appelé avant toute autre fonction.

#### `Logger_Term()`
Termine le service de journalisation proprement.

### Procédures de journalisation

#### `Logger_Debug(message)`
Enregistre un message de débogage (niveau 0).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

#### `Logger_Info(message)`
Enregistre un message d'information (niveau 1).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

#### `Logger_Warning(message)`
Enregistre un message d'avertissement (niveau 2).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

#### `Logger_Error(message)`
Enregistre un message d'erreur (niveau 3).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

#### `Logger_Fatal(message)`
Enregistre un message d'erreur fatale (niveau 4).
- **Paramètre** : `message` - Message à enregistrer (VARCHAR 512)

### Procédures de configuration

#### `Logger_SetLevel(level)`
Définit le niveau minimum de journalisation.
- **Paramètre** : `level` - Niveau (0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=FATAL)

#### `Logger_GetLevel()`
Retourne le niveau de journalisation actuel.
- **Retour** : Niveau actuel (INT 10)

## 📁 Structure du projet

```
logfori/
├── qrpglesrc/
│   ├── LOGGER.SQLRPGLE      # Module principal du service de log
│   └── TESTLOGGER.SQLRPGLE  # Programme de test
├── qsrvsrc/
│   └── LOGGER.BND           # Source de liaison (binding)
├── qcmdsrc/
│   ├── CRTLOGGER.CMD        # Définition de commande
│   └── CRTLOGGER.CLLE       # Programme CL de compilation
├── README.md                 # Cette documentation
└── LICENSE                   # Licence du projet
```

## 🎯 Fonctionnalités avancées

### Filtrage par niveau

Le système de niveaux permet de filtrer les messages :

```rpgle
// Niveau INFO : affiche INFO, WARNING, ERROR, FATAL (pas DEBUG)
Logger_SetLevel(LOG_LEVEL_INFO);

// Niveau WARNING : affiche seulement WARNING, ERROR, FATAL
Logger_SetLevel(LOG_LEVEL_WARNING);

// Niveau ERROR : affiche seulement ERROR et FATAL
Logger_SetLevel(LOG_LEVEL_ERROR);
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

- [IBM i Documentation](https://www.ibm.com/docs/en/i)
- [ILE RPG Reference](https://www.ibm.com/docs/en/i/7.5?topic=languages-ile-rpg)
- [Service Programs](https://www.ibm.com/docs/en/i/7.5?topic=programs-service)

## ⚠️ Notes

- Le service écrit actuellement dans stdout via `Qp0zLprintf`
- Pour écrire dans QSYSOPR, décommenter la section correspondante dans `writeLog()`
- Testé sur IBM i 7.3+
- Supporte les caractères Unicode et les caractères spéciaux français
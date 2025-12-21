# LOGFORI - Instructions pour l'assistant IA

## Architecture du projet

LOGFORI est un **service de journalisation thread-safe** pour IBM i, fourni comme programme de service (*SRVPGM). L'architecture suit le pattern service/client classique d'IBM i :

- **Service** : [qrpglesrc/LOGGER.SQLRPGLE](../qrpglesrc/LOGGER.SQLRPGLE) - Module `nomain` avec `thread(*serialize)` exportant des procédures via [qsrvsrc/LOGGER.BND](../qsrvsrc/LOGGER.BND)
- **API** : [qcpysrc/LOGGERAPI.RPGLEINC](../qcpysrc/LOGGERAPI.RPGLEINC) - Fichier de copie réutilisable avec prototypes et constantes
- **Client** : [qrpglesrc/TESTLOGGER.PGM.RPGLE](../qrpglesrc/TESTLOGGER.PGM.RPGLE) - Programme de test avec `actgrp(*new)` et `bnddir('SERVICES')`

### Décisions architecturales clés

1. **Thread-safe par design** : `ctl-opt thread(*serialize)` dans LOGGER garantit l'accès sérialisé
2. **Module nomain** : LOGGER.SQLRPGLE utilise `ctl-opt nomain` car c'est un module de service sans point d'entrée principal
3. **Variables globales** : `gInitialized` et `gLogLevel` maintiennent l'état entre appels (autorisé car thread-safe)
4. **Pas de valeur de retour utilisée** : Toutes les procédures de log (sauf `LoggerGetLevel`) retournent `void` - les prototypes ne définissent pas les sous-procédures avec type de retour
5. **API système** : Utilise `Qp0zLprintf()` pour écrire vers joblog (visible dans QSYSPRT ou journaux)

## Conventions de codage spécifiques

### Format et style RPG
```rpgle
**FREE
ctl-opt nomain thread(*serialize);  // Obligatoire pour modules service

// Indentation: 2 espaces
// Noms exportés: PascalCase (LoggerInit, LoggerInfo)
// Variables locales: camelCase
// Constantes: UPPER_SNAKE_CASE avec préfixes LOG_*
// Commentaires: Français avec documentation iledocs (///)
```

### Déclarations obligatoires
Toutes les procédures exportées nécessitent **trois déclarations** :
1. Prototype dans LOGGER.SQLRPGLE (section prototypes exportés) - **OPTIONNEL** pour modules nomain
2. Export dans LOGGER.BND (`EXPORT SYMBOL('ProcName')`)
3. Prototype dans LOGGERAPI.RPGLEINC avec `extproc()` explicite

**Note importante** : Pour les modules `nomain`, les prototypes internes sont optionnels si les procédures sont déclarées avant leur utilisation, ou si le compilateur peut les inférer. Cependant, il est recommandé de les inclure pour la lisibilité.

### Pattern d'implémentation standard
```rpgle
dcl-proc LoggerNouveauNiveau export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;
  
  if gLogLevel <= LOG_LEVEL_NOUVEAUNIVEAU;
    writeLog(LOG_PREFIX_NOUVEAUNIVEAU : message);
  endif;
end-proc;
```

## Workflows de développement

### Compilation avec TOBI

```bash
makei compile             # Compile le service complet (module + *SRVPGM + BNDDIR)
makei OBJLIB=MYLIB compile # Spécifier une bibliothèque cible
makei test                # Compile le programme de test
makei example             # Compile le programme d'exemple
makei clean               # Nettoie les objets compilés
```

TOBI utilise les fichiers `Rules.mk` dans chaque répertoire pour définir les dépendances. Configuration dans [iproj.json](../iproj.json).

**Avantages TOBI** :
- Gestion automatique des dépendances entre objets
- Parallélisation des compilations
- Standard IBM i moderne (CI/CD friendly)
- Reconstruction intelligente (seulement ce qui a changé)
- Pas besoin de créer la bibliothèque manuellement

### Cibles de compilation

- `compile` : Compile LOGGER.MODULE → LOGGER.SRVPGM → SERVICES.BNDDIR
- `test` : Compile le service + TESTLOGGER.PGM (n'exécute pas le programme)
- `example` : Compile EXAMPLE.PGM qui utilise le service
- `clean` : Supprime tous les objets compilés

### Test et validation

```bash
# Compiler le programme de test
makei test

# Exécuter manuellement le programme de test
system "CALL &CURLIB/TESTLOGGER"

# Compiler le programme d'exemple
makei example
```

Le programme de test [TESTLOGGER.PGM.RPGLE](../qrpglesrc/TESTLOGGER.PGM.RPGLE) change dynamiquement `gLogLevel` pour vérifier le filtrage. 

Le programme d'exemple [EXAMPLE.PGM.SQLRPGLE](../qrpglesrc/EXAMPLE.PGM.SQLRPGLE) montre une utilisation basique avec `/copy qcpysrc,loggerapi`.

### Journalisation des erreurs de compilation
Les erreurs de compilation apparaissent dans le job log. Pour déboguer :
```bash
# Voir les derniers messages du job
system "DSPJOBLOG"

# Ou compiler manuellement en mode interactif pour voir les erreurs
system "CRTSQLRPGI OBJ(MYLIB/LOGGER) SRCSTMF('qrpglesrc/LOGGER.SQLRPGLE') OBJTYPE(*MODULE)"
```

## Patterns spécifiques à IBM i

### Gestion de l'état global thread-safe
```rpgle
dcl-s gLogLevel int(10) inz(LOG_LEVEL_INFO);  // État partagé OK avec thread(*serialize)
dcl-s gInitialized ind inz(*off);             // Protège contre double init
```

### Binding directory pour dépendances

Les programmes clients utilisent `bnddir('SERVICES')` au lieu de `bndsrvpgm(MYLIB/LOGGER)` :
- Plus flexible (pas de référence hardcodée à la bibliothèque)
- Le BNDDIR `SERVICES` créé automatiquement par TOBI contient la référence au *SRVPGM LOGGER
- Défini dans [qbndsrc/SERVICES.BNDDIR](../qbndsrc/SERVICES.BNDDIR)

```rpgle
**FREE
ctl-opt dftactgrp(*no) actgrp(*new) bnddir('SERVICES');

/copy qcpysrc,loggerapi  // Importe tous les prototypes

LoggerInit();
LoggerInfo('Application démarrée');
LoggerTerm();
```

### Signature de binding
LOGGER.BND définit `SIGNATURE('LOGGER V1.0')` - **Important** : changer la signature force la recompilation de tous les clients lors de modifications incompatibles.

## Fichiers critiques

### Build et configuration
- [iproj.json](../iproj.json) : Configuration du projet TOBI (version, description, chemins d'inclusion)
- [Rules.mk](../Rules.mk) : Règles de compilation Make racine - définit les sous-répertoires
- [qrpglesrc/Rules.mk](../qrpglesrc/Rules.mk) : Dépendances pour modules et programmes RPG
- [qsrvsrc/Rules.mk](../qsrvsrc/Rules.mk) : Dépendances pour le service program
- [qbndsrc/Rules.mk](../qbndsrc/Rules.mk) : Dépendances pour le binding directory

### Code source et API
- [qsrvsrc/LOGGER.BND](../qsrvsrc/LOGGER.BND) : Définit l'interface publique du service - tout ajout de procédure nécessite un `EXPORT SYMBOL()` ici
- [qcpysrc/LOGGERAPI.RPGLEINC](../qcpysrc/LOGGERAPI.RPGLEINC) : Fichier de copie utilisé par les clients - maintenir synchronisé avec LOGGER.SQLRPGLE

### Utilisation de LOGGERAPI.RPGLEINC

Les programmes clients peuvent utiliser `/copy` au lieu de déclarer tous les prototypes manuellement :

```rpgle
**FREE
ctl-opt dftactgrp(*no) actgrp(*new) bnddir('SERVICES');

/copy qcpysrc,loggerapi  // Obtient tous les prototypes et constantes

LoggerInit();
LoggerInfo('Application démarrée');
LoggerTerm();
```

**Configuration des chemins** : Le fichier LOGGERAPI.RPGLEINC est dans `qcpysrc/`. Le compilateur le trouve grâce à la configuration dans `iproj.json` :

```json
{
  "includePath": [
    "/home/OLIVIER/builds/logfori/qcpysrc"
  ]
}
```

Le fichier RPGLEINC contient des gardes de compilation (`/IF NOT DEFINED(LOGGERAPI)`) pour éviter les inclusions doubles.

## Commandes de dépannage

### Erreurs de compilation TOBI

```bash
# Consulter les logs TOBI (contient les erreurs de compilation détaillées)
cat .logs/joblog.json

# Voir les erreurs du job actuel
system "DSPJOBLOG"

# Compiler manuellement pour voir les erreurs détaillées
system "CRTSQLRPGI OBJ(MYLIB/LOGGER) SRCSTMF('qrpglesrc/LOGGER.SQLRPGLE') OBJTYPE(*MODULE) DBGVIEW(*SOURCE)"

# Si CRTSRVPGM échoue, vérifier que :
# 1. Le module LOGGER existe : WRKOBJ OBJ(MYLIB/LOGGER) OBJTYPE(*MODULE)
# 2. Le fichier LOGGER.BND est accessible : ls qsrvsrc/LOGGER.BND
# 3. Tous les symboles exportés dans LOGGER.BND correspondent aux procédures avec 'export'
```

**Erreurs TOBI spécifiques** :

Si `makei compile` échoue avec "Failed to create LOGGER.SRVPGM", vérifier :
- Le fichier `.logs/joblog.json` contient les détails de l'erreur de compilation
- La commande exacte utilisée est visible dans la sortie de makei avec `-v`
- Module LOGGER non créé ou incomplet - vérifier d'abord `WRKOBJ OBJ(&CURLIB/LOGGER) OBJTYPE(*MODULE)`

**Dépendances TOBI** :

Les fichiers `Rules.mk` définissent les dépendances :
- `qrpglesrc/Rules.mk` : `LOGGER.MODULE: LOGGER.SQLRPGLE`
- `qsrvsrc/Rules.mk` : `LOGGER.SRVPGM: LOGGER.BND LOGGER.MODULE`
- `qbndsrc/Rules.mk` : `SERVICES.BNDDIR: SERVICES.BNDDIR LOGGER.SRVPGM`
- Racine `Rules.mk` : `SUBDIRS = qrpglesrc qsrvsrc qbndsrc`

Si un objet ne se compile pas, TOBI remonte l'erreur depuis le sous-répertoire concerné.

## Extensions planifiées

Voir [CONTRIBUTING.md](../CONTRIBUTING.md) pour les fonctionnalités souhaitées. Priorités :
- **Rotation de logs** : Ajout de procédures `LoggerSetOutputFile()` et `LoggerRotateLogs()`
- **Logs structurés** : Support JSON via nouvelle procédure `LoggerLogJSON()`
- **Catégories** : Filtrage par module avec `LoggerInitCategory(categoryName)`

Toute nouvelle procédure exportée doit suivre le triple-pattern déclaration (prototype + BND + RPGLEINC).

# LOGFORI - Instructions pour l'assistant IA

## Architecture du projet

LOGFORI est un **service de journalisation thread-safe** pour IBM i, fourni comme programme de service (*SRVPGM). L'architecture suit le pattern service/client classique d'IBM i :

- **Service** : [qrpglesrc/LOGGER.SQLRPGLE](../qrpglesrc/LOGGER.SQLRPGLE) - Module `nomain` avec `thread(*serialize)` exportant des procédures via [qsrvsrc/LOGGER.BND](../qsrvsrc/LOGGER.BND)
- **API** : [qcpysrc/LOGGERAPI.RPGLEINC](../qcpysrc/LOGGERAPI.RPGLEINC) - Fichier de copie réutilisable avec prototypes et constantes
- **Client** : [qrpglesrc/TESTLOGGER.SQLRPGLE](../qrpglesrc/TESTLOGGER.SQLRPGLE) - Programme de test avec `actgrp(*new)` et `bnddir('LOGGER')`

### Décisions architecturales clés

1. **Thread-safe par design** : `ctl-opt thread(*serialize)` dans LOGGER garantit l'accès sérialisé
2. **Module nomain** : LOGGER.SQLRPGLE utilise `ctl-opt nomain` car c'est un module de service sans point d'entrée principal
3. **Variables globales** : `gInitialized` et `gLogLevel` maintiennent l'état entre appels (autorisé car thread-safe)
4. **Pas de valeur de retour utilisée** : Toutes les procédures de log (sauf `Logger_GetLevel`) retournent `void` - les prototypes ne définissent pas `*n` avec type de retour
5. **API système** : Utilise `Qp0zLprintf()` pour écrire vers stdout (visible dans QSYSPRT ou journaux)

## Conventions de codage spécifiques

### Format et style RPG
```rpgle
**FREE
ctl-opt nomain thread(*serialize);  // Obligatoire pour modules service

// Indentation: 2 espaces
// Noms exportés: Logger_PascalCase
// Variables locales: camelCase
// Constantes: UPPER_SNAKE_CASE avec préfixes LOG_*
// Commentaires: Français avec documentation JavaDoc (///)
```

### Déclarations obligatoires
Toutes les procédures exportées nécessitent **trois déclarations** :
1. Prototype dans LOGGER.SQLRPGLE (section prototypes exportés) - **OPTIONNEL** pour modules nomain
2. Export dans LOGGER.BND (`EXPORT SYMBOL('ProcName')`)
3. Prototype dans LOGGERAPI.RPGLEINC avec `extproc()` explicite

**Note importante** : Pour les modules `nomain`, les prototypes internes sont optionnels si les procédures sont déclarées avant leur utilisation, ou si le compilateur peut les inférer. Cependant, il est recommandé de les inclure pour la lisibilité.

### Pattern d'implémentation standard
```rpgle
dcl-proc Logger_NouveauNiveau export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;
  
  if gLogLevel <= LOG_LEVEL_NOUVEAUNIVEAU;
    writeLog(LOG_PREFIX_NOUVEAUNIVEAU : message);
  endif;
end-proc;
```

## Workflows de développement

### Compilation avec TOBI (méthode recommandée)
```bash
makei all                 # Compile le service complet (module + *SRVPGM + BNDDIR)
makei OBJLIB=MYLIB all    # Spécifier une bibliothèque cible
makei test                # Compile et exécute les tests
makei clean               # Nettoie les objets compilés
```
TOBI utilise [Rules.mk](../Rules.mk) pour définir les règles de compilation. Configuration dans [iproj.json](../iproj.json).

**Avantages TOBI** :
- Gestion automatique des dépendances entre objets
- Parallélisation des compilations
- Standard IBM i moderne (CI/CD friendly)
- Pas besoin de créer la bibliothèque manuellement

### Compilation avec scripts shell (alternative)
```bash
./build.sh MYLIB          # Compile module + crée *SRVPGM + crée BNDDIR
```
Le script crée automatiquement la bibliothèque si absente. Étapes :
1. CRTSQLRPGI → module (*MODULE) avec `OBJTYPE(*MODULE) COMMIT(*NONE)`
2. CRTSRVPGM avec `EXPORT(*SRCFILE)` pointant vers LOGGER.BND et `ACTGRP(*CALLER)`
3. CRTBNDDIR + ADDBNDDIRE pour liaison simplifiée

**Attention** : Le module LOGGER utilise `COMMIT(*NONE)` - ne pas changer car le service ne gère pas de transactions.

### Test et validation
```bash
# Avec TOBI (recommandé)
makei test                # Compile et exécute automatiquement les tests

# Avec script shell
./build_test.sh MYLIB     # Compile TESTLOGGER lié à LOGGER *SRVPGM
system "CALL MYLIB/TESTLOGGER"  # Exécute tests avec différents niveaux
```
Le programme de test change dynamiquement `gLogLevel` pour vérifier le filtrage. TESTLOGGER utilise `BNDSRVPGM(MYLIB/LOGGER)` directement (pas via BNDDIR) pour tester la liaison explicite.

### Alternative CL
```bashmakei` (TOBI) ou `build.sh` pour plus de fonctionnalités
system "CLLE SRCSTMF('qcmdsrc/CRTLOGGER.CLLE')"
system "CALL CRTLOGGER PARM('MYLIB')"
```
Le programme CL [CRTLOGGER.CLLE](../qcmdsrc/CRTLOGGER.CLLE) utilise `MONMSG MSGID(CPF0000)` pour gérer les erreurs et envoie des messages de progression avec `SNDPGMMSG`. Préférer `build.sh` pour plus de lisibilité.

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
Les programmes clients utilisent `bnddir('LOGGER')` au lieu de `bndsrvpgm(MYLIB/LOGGER)` :
- Plus flexible (pas de référence hardcodée à la bibliothèque)
- Le BNDDIR créé par build.sh contient la référence au *SRVPGM

### Signature de binding
LOGGER.BND définit `SIGNATURE('LOGGER V1.0')` - **Important** : changer la signature force la recompilation de tous les clients lors de modifications incompatibles.

## Fichiers critiques

### Build et configuration
- [iproj.json](../iproj.json) : Configuration du projet TOBI (version, description, chemins d'inclusion)
- [Rules.mk](../Rules.mk) : Règles de compilation Make pour TOBI - définit les cibles et dépendances
- [build.sh](../build.sh) : Script shell alternatif avec gestion d'erreurs et messages de progression
- [BUILD_WITH_TOBI.md](../BUILD_WITH_TOBI.md) : Documentation complète pour l'utilisation de TOBI

### Code source et API
- [qsrvsrc/LOGGER.BND](../qsrvsrc/LOGGER.BND) : Définit l'interface publique du service - tout ajout de procédure nécessite un `EXPORT SYMBOL()` ici
- [LOGGERAPI.RPGLEINC](../qrpglesrc/LOGGERAPI.RPGLEINC) : Fichier de copie utilisé par les clients - maintenir synchronisé avec LOGGER.SQLRPGLE

### Utilisation de LOGGERAPI.RPGLEINC
Les programmes clients peuvent utiliser `/copy` ou `/include` au lieu de déclarer tous les prototypes manuellement :
```rpgle
**FREE
ctl-opt dftactgrp(*no) actgrp(*new) bnddir('LOGGER');

/copy qcpysrc,loggerapi  // Obtient tous les prototypes et constantes

Logger_Init();
Logger_Info('Application démarrée');
Logger_Term();
```
**IMPORTANT** : Le fichier LOGGERAPI.RPGLEINC est dans `qcpysrc/`, pas `qrpglesrc/`. Le chemin doit être configuré dans `iproj.json` (clé `includePaths`) pour que le compilateur le trouve.

**ATTENTION** : Actuellement, `iproj.json` inclut seulement `"qrpglesrc"` dans `includePaths`. Pour utiliser `/copy qcpysrc,loggerapi`, il faut ajouter `"qcpysrc"` aux `includePaths` :
```json
"includePaths": [
  "qrpglesrc",
  "qcpysrc"
]
```

Le fichier RPGLEINC contient des gardes de compilation (`/IF NOT DEFINED(LOGGERAPI)`) pour éviter les inclusions doubles.

## Commandes de dépannage

### Erreurs de compilation
```bash
# Vérifier les erreurs du job actuel
system "DSPJOBLOG"

# Compiler manuellement pour voir les erreurs détaillées
system "CRTSQLRPGI OBJ(MYLIB/LOGGER) SRCSTMF('qrpglesrc/LOGGER.SQLRPGLE') OBJTYPE(*MODULE) DBGVIEW(*SOURCE)"

# Si CRTSRVPGM échoue, vérifier que :
# 1. Le module LOGGER existe : WRKOBJ OBJ(MYLIB/LOGGER) OBJTYPE(*MODULE)
# 2. Le fichier LOGGER.BND est accessible : ls qsrvsrc/LOGGER.BND
# 3. Tous les symboles exportés dans LOGGER.BND correspondent aux procédures avec 'export'
```

### Vérification des objets
```bash
# Vérifier les exports du *SRVPGM
system "DSPSRVPGM SRVPGM(MYLIB/LOGGER)"

# Lister les objets liés à un programme
system "DSPPGM PGM(MYLIB/TESTLOGGER)"

# Voir le contenu du BNDDIR
system "DSPBNDDIR BNDDIR(MYLIB/LOGGER)"

# Journaux QSYSPRT (contient la sortie de Qp0zLprintf)
system "WRKSPLF SELECT(TESTLOGGER)"
```

### Erreurs TOBI spécifiques
Si `makei all` échoue avec "Failed to create LOGGER.SRVPGM", vérifier :
- Le fichier `.evfevent` contient les détails de l'erreur de compilation
- Les logs dans `.logs/` montrent l'erreur exacte du compilateur
- La commande exacte utilisée est visible dans la sortie de makei
- **Cause fréquente** : Module LOGGER non créé ou incomplet - vérifier d'abord `WRKOBJ OBJ(BUILDLIB/LOGGER) OBJTYPE(*MODULE)`

### Structure des Rules.mk
Les fichiers Rules.mk définissent les dépendances pour TOBI :
- `qrpglesrc/Rules.mk` : `LOGGER.MODULE: LOGGER.SQLRPGLE`
- `qsrvsrc/Rules.mk` : `LOGGER.SRVPGM: LOGGER.BND LOGGER.MODULE`
- Racine `Rules.mk` : `SUBDIRS = QCMDSRC QRPGLESRC QSRVSRC`

Si un objet ne se compile pas, TOBI remonte l'erreur depuis le sous-répertoire concerné.

## Extensions planifiées

Voir [CONTRIBUTING.md](../CONTRIBUTING.md) pour les fonctionnalités souhaitées. Priorités :
- **Rotation de logs** : Ajout de procédures `Logger_SetOutputFile()` et `Logger_RotateLogs()`
- **Logs structurés** : Support JSON via nouvelle procédure `Logger_LogJSON()`
- **Catégories** : Filtrage par module avec `Logger_InitCategory(categoryName)`

Toute nouvelle procédure exportée doit suivre le triple-pattern déclaration (prototype + BND + RPGLEINC).

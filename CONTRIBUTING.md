# Guide de contribution à LOGFORI

Merci de votre intérêt pour contribuer à LOGFORI ! Ce document explique comment contribuer au projet.

## 📋 Prérequis pour contribuer

- Connaissance d'ILE RPG (format libre de préférence)
- Accès à un système IBM i (7.3 ou supérieur) pour tester
- Compte GitHub pour soumettre des Pull Requests

## 🔧 Configuration de l'environnement de développement

1. Fork le projet sur GitHub
2. Cloner votre fork localement ou sur IBM i
3. Créer une branche pour votre fonctionnalité :
   ```bash
   git checkout -b feature/ma-nouvelle-fonctionnalite
   ```

## 📝 Conventions de code

### Style RPG

- Utiliser le format libre (`**FREE`)
- Indentation : 2 espaces
- Commentaires en français
- Documentation ILEDoc pour les procédures exportées
- Noms de procédures en PascalCase sans underscore
- Variables locales en camelCase
- Constantes en UPPER_SNAKE_CASE

### Exemple de documentation

```rpgle
///
/// LoggerInfo - Enregistre un message d'information
///
/// @param message Message à enregistrer
///
dcl-proc LoggerInfo export;
  dcl-pi *n varchar(512) const;
    message varchar(512) const;
  end-pi;
  
  // Implémentation...
end-proc;
```

## 🧪 Tests

Avant de soumettre une Pull Request :

1. Compiler le service avec `makei compile`
2. Compiler les tests avec `makei test`
3. Exécuter le programme de test : `system "CALL &CURLIB/TESTLOGGER"`
4. Vérifier que tous les niveaux de log fonctionnent correctement
5. Compiler l'exemple avec `makei example`
6. Tester avec vos changements dans un programme réel

### Commandes TOBI utiles

```bash
makei compile        # Compile le service LOGGER
makei test          # Compile le programme de test
makei example       # Compile le programme d'exemple
makei clean         # Nettoie les objets compilés
makei OBJLIB=MYLIB compile  # Compile dans une bibliothèque spécifique

# Exécuter les tests (après compilation)
CALL &CURLIB/TESTLOGGER"```

## 🚀 Processus de contribution

1. **Créer une issue** pour discuter du changement proposé
2. **Développer** votre fonctionnalité dans une branche dédiée
3. **Tester** soigneusement vos changements
4. **Commiter** avec des messages clairs et descriptifs
5. **Pousser** votre branche vers votre fork
6. **Créer une Pull Request** vers la branche principale

### Format des messages de commit

```
Type: Description courte (50 caractères max)

Description détaillée si nécessaire (72 caractères par ligne).

Résout : #numéro_issue
```

Types de commit :
- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation uniquement
- `style:` Formatage, point-virgule manquant, etc.
- `refactor:` Refactoring du code
- `test:` Ajout ou modification de tests
- `chore:` Maintenance, mise à jour des dépendances

## 💡 Idées de contribution

Voici quelques idées pour contribuer :

### Fonctionnalités souhaitées

- [ ] Support pour écrire dans un fichier IFS en plus du joblog
- [ ] Support pour écrire dans une table de base de données
- [ ] Rotation automatique des logs
- [ ] Filtrage par catégorie ou module
- [ ] Support pour les messages multi-lignes
- [ ] Configuration via fichier JSON ou XML
- [ ] API pour récupérer l'historique des logs
- [ ] Support pour les logs structurés (JSON)
- [ ] Intégration avec Syslog
- [ ] Performance monitoring et statistiques

### Améliorations de la documentation

- [ ] Ajouter plus d'exemples d'utilisation
- [ ] Créer un guide de démarrage rapide
- [ ] Ajouter des diagrammes de flux
- [ ] Documenter les cas d'usage avancés
- [ ] Traduction en anglais

### Tests et qualité

- [ ] Ajouter des tests unitaires
- [ ] Créer des tests d'intégration
- [ ] Ajouter des benchmarks de performance
- [ ] Créer des exemples pour différents cas d'usage

## 🐛 Signaler un bug

Pour signaler un bug, créez une issue avec :

1. **Titre clair** décrivant le problème
2. **Version** d'IBM i utilisée
3. **Description** du comportement attendu vs actuel
4. **Code** minimal pour reproduire le problème
5. **Messages d'erreur** complets si disponibles
6. **Logs** pertinents

## 📞 Questions et support

- **Issues GitHub** : Pour les bugs et demandes de fonctionnalités
- **Discussions GitHub** : Pour les questions et discussions générales

## 📄 Licence

En contribuant à LOGFORI, vous acceptez que vos contributions soient sous licence Apache 2.0.

## 🙏 Remerciements

Merci à tous les contributeurs qui aident à améliorer LOGFORI !

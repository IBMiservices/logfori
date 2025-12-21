**FREE
///
/// EXAMPLE - Exemple simple d'utilisation du service LOGGER
///
/// Cet exemple montre comment utiliser le fichier de copie LOGGERAPI
/// pour simplifier l'utilisation du service de journalisation.
///

ctl-opt dftactgrp(*no) actgrp(*new) bnddir('SERVICES');

//*************************************************************
// Inclure l'API du service LOGGER
//*************************************************************

/copy qrpglesrc,loggerapi

//*************************************************************
// Programme principal
//*************************************************************

// Initialiser le service de journalisation
LoggerInit();

// Exemple d'utilisation dans une application
LoggerInfo('Application exemple démarrée');
LoggerDebug('Variable1 = ' + %char(100));

// Simuler un traitement
LoggerInfo('Début du traitement des données');

// Simuler un avertissement
LoggerWarning('Enregistrement en double détecté, ignoré');

// Simuler une erreur gérée
LoggerError('Impossible de lire le fichier CONFIG, valeurs par défaut utilisées');

LoggerInfo('Traitement terminé avec succès');

// Terminer le service
LoggerTerm();

*inlr = *on;

**FREE
///
/// EXAMPLE - Exemple simple d'utilisation du service LOGGER
///
/// Cet exemple montre comment utiliser le fichier de copie LOGGERAPI
/// pour simplifier l'utilisation du service de journalisation.
///

ctl-opt dftactgrp(*no) actgrp(*new) bnddir('LOGGER');

//*************************************************************
// Inclure l'API du service LOGGER
//*************************************************************

/copy qrpglesrc,loggerapi

//*************************************************************
// Programme principal
//*************************************************************

// Initialiser le service de journalisation
Logger_Init();

// Exemple d'utilisation dans une application
Logger_Info('Application exemple démarrée');
Logger_Debug('Variable1 = ' + %char(100));

// Simuler un traitement
Logger_Info('Début du traitement des données');

// Simuler un avertissement
Logger_Warning('Enregistrement en double détecté, ignoré');

// Simuler une erreur gérée
Logger_Error('Impossible de lire le fichier CONFIG, valeurs par défaut utilisées');

Logger_Info('Traitement terminé avec succès');

// Terminer le service
Logger_Term();

*inlr = *on;

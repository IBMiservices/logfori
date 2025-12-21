**FREE
///
/// TESTLOGGER - Programme de test pour le service LOGGER
///
/// Ce programme démontre l'utilisation des fonctions de journalisation
/// fournies par le programme de service LOGGER.
///

ctl-opt dftactgrp(*no) actgrp('TESTLOGGER') bnddir('SERVICES');

//*************************************************************
// Prototypes des fonctions du service LOGGER
//*************************************************************

/copy 'LOGGERAPI.RPGLEINC'


//*************************************************************
// Programme principal
//*************************************************************

dcl-s currentLevel int(10);

// Initialiser le service de journalisation
LoggerInit();

// Test des différents niveaux de log avec niveau INFO par défaut
LoggerInfo('=== Test avec niveau INFO (défaut) ===');
LoggerDebug('Ce message ne devrait pas apparaître');
LoggerInfo('Message d''information');
LoggerWarning('Message d''avertissement');
LoggerError('Message d''erreur');
LoggerFatal('Message d''erreur fatale');

// Changer le niveau à DEBUG
LoggerSetLevel(LOG_LEVEL_DEBUG);
currentLevel = LoggerGetLevel();
LoggerInfo('=== Niveau changé à DEBUG (' + %char(currentLevel) + ') ===');
LoggerDebug('Ce message de débogage devrait maintenant apparaître');
LoggerInfo('Message d''information avec niveau DEBUG');

// Changer le niveau à WARNING
LoggerSetLevel(LOG_LEVEL_WARNING);
currentLevel = LoggerGetLevel();
LoggerInfo('=== Niveau changé à WARNING (' + %char(currentLevel) + ') ===');
LoggerDebug('Ce message DEBUG ne devrait pas apparaître');
LoggerInfo('Ce message INFO ne devrait pas apparaître');
LoggerWarning('Ce message WARNING devrait apparaître');
LoggerError('Ce message ERROR devrait apparaître');

// Changer le niveau à ERROR
LoggerSetLevel(LOG_LEVEL_ERROR);
currentLevel = LoggerGetLevel();
LoggerInfo('=== Niveau changé à ERROR (' + %char(currentLevel) + ') ===');
LoggerWarning('Ce message WARNING ne devrait pas apparaître');
LoggerError('Ce message ERROR devrait apparaître');
LoggerFatal('Ce message FATAL devrait apparaître');

// Test avec des messages complexes
LoggerSetLevel(LOG_LEVEL_INFO);
LoggerInfo('=== Test avec messages complexes ===');
LoggerInfo('Test avec des caractères spéciaux: àéèêô ç');
LoggerInfo('Test avec des nombres: ' + %char(12345));
LoggerWarning('Test d''avertissement avec apostrophe');

// Terminer le service de journalisation
LoggerTerm();

*inlr = *on;

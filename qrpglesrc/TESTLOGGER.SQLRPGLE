**FREE
///
/// TESTLOGGER - Programme de test pour le service LOGGER
///
/// Ce programme démontre l'utilisation des fonctions de journalisation
/// fournies par le programme de service LOGGER.
///

ctl-opt dftactgrp(*no) actgrp(*new) bnddir('LOGGER');

//*************************************************************
// Prototypes des fonctions du service LOGGER
//*************************************************************

dcl-pr Logger_Init extproc('Logger_Init') end-pr;
dcl-pr Logger_Term extproc('Logger_Term') end-pr;
dcl-pr Logger_Debug extproc('Logger_Debug') varchar(512) const;
  message varchar(512) const;
end-pr;
dcl-pr Logger_Info extproc('Logger_Info') varchar(512) const;
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
dcl-pr Logger_GetLevel int(10) extproc('Logger_GetLevel') end-pr;

//*************************************************************
// Constantes pour les niveaux de log
//*************************************************************

dcl-c LOG_LEVEL_DEBUG 0;
dcl-c LOG_LEVEL_INFO 1;
dcl-c LOG_LEVEL_WARNING 2;
dcl-c LOG_LEVEL_ERROR 3;
dcl-c LOG_LEVEL_FATAL 4;

//*************************************************************
// Programme principal
//*************************************************************

dcl-s currentLevel int(10);

// Initialiser le service de journalisation
Logger_Init();

// Test des différents niveaux de log avec niveau INFO par défaut
Logger_Info('=== Test avec niveau INFO (défaut) ===');
Logger_Debug('Ce message ne devrait pas apparaître');
Logger_Info('Message d''information');
Logger_Warning('Message d''avertissement');
Logger_Error('Message d''erreur');
Logger_Fatal('Message d''erreur fatale');

// Changer le niveau à DEBUG
Logger_SetLevel(LOG_LEVEL_DEBUG);
currentLevel = Logger_GetLevel();
Logger_Info('=== Niveau changé à DEBUG (' + %char(currentLevel) + ') ===');
Logger_Debug('Ce message de débogage devrait maintenant apparaître');
Logger_Info('Message d''information avec niveau DEBUG');

// Changer le niveau à WARNING
Logger_SetLevel(LOG_LEVEL_WARNING);
currentLevel = Logger_GetLevel();
Logger_Info('=== Niveau changé à WARNING (' + %char(currentLevel) + ') ===');
Logger_Debug('Ce message DEBUG ne devrait pas apparaître');
Logger_Info('Ce message INFO ne devrait pas apparaître');
Logger_Warning('Ce message WARNING devrait apparaître');
Logger_Error('Ce message ERROR devrait apparaître');

// Changer le niveau à ERROR
Logger_SetLevel(LOG_LEVEL_ERROR);
currentLevel = Logger_GetLevel();
Logger_Info('=== Niveau changé à ERROR (' + %char(currentLevel) + ') ===');
Logger_Warning('Ce message WARNING ne devrait pas apparaître');
Logger_Error('Ce message ERROR devrait apparaître');
Logger_Fatal('Ce message FATAL devrait apparaître');

// Test avec des messages complexes
Logger_SetLevel(LOG_LEVEL_INFO);
Logger_Info('=== Test avec messages complexes ===');
Logger_Info('Test avec des caractères spéciaux: àéèêô ç');
Logger_Info('Test avec des nombres: ' + %char(12345));
Logger_Warning('Test d''avertissement avec apostrophe');

// Terminer le service de journalisation
Logger_Term();

*inlr = *on;

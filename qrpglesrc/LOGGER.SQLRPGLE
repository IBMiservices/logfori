**FREE
///
/// LOGGER - Service de journalisation pour IBM i
///
/// Ce module fournit des fonctions de log pour les applications IBM i.
/// Il permet d'écrire des messages dans le journal système avec différents
/// niveaux de sévérité.
///
/// @author IBM i Services
/// @version 1.0.0
///

ctl-opt nomain thread(*serialize);

//*************************************************************
// Prototypes des procédures exportées
//*************************************************************



//*************************************************************
// Constantes
//*************************************************************

dcl-c LOG_LEVEL_DEBUG 0;
dcl-c LOG_LEVEL_INFO 1;
dcl-c LOG_LEVEL_WARNING 2;
dcl-c LOG_LEVEL_ERROR 3;
dcl-c LOG_LEVEL_FATAL 4;

dcl-c LOG_PREFIX_DEBUG 'DEBUG';
dcl-c LOG_PREFIX_INFO 'INFO';
dcl-c LOG_PREFIX_WARNING 'WARNING';
dcl-c LOG_PREFIX_ERROR 'ERROR';
dcl-c LOG_PREFIX_FATAL 'FATAL';

dcl-c NEWLINE x'25';

//*************************************************************
// Variables globales
//*************************************************************

dcl-s gLogLevel int(10) inz(LOG_LEVEL_INFO);
dcl-s gInitialized ind inz(*off);

//*************************************************************
// Prototypes des API système
//*************************************************************

dcl-pr Qp0zLprintf int(10) extproc('Qp0zLprintf');
  format pointer value options(*string);
end-pr;

dcl-pr system int(10) extproc('system');
  command pointer value options(*string);
end-pr;

//*************************************************************
// Implémentation des procédures
//*************************************************************

///
/// Logger_Init - Initialise le service de journalisation
///
dcl-proc Logger_Init export;
  if not gInitialized;
    gInitialized = *on;
    gLogLevel = LOG_LEVEL_INFO;
    // Ne pas logger ici pour éviter la récursion pendant l'initialisation
  endif;
end-proc;

///
/// Logger_Term - Termine le service de journalisation
///
dcl-proc Logger_Term export;
  if gInitialized;
    // Logger le message avant de désactiver le service
    writeLog(LOG_PREFIX_INFO : 'Service de journalisation terminé');
    gInitialized = *off;
  endif;
end-proc;

///
/// Logger_Debug - Enregistre un message de débogage
///
/// @param message Message à enregistrer
///
dcl-proc Logger_Debug export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_DEBUG;
    writeLog(LOG_PREFIX_DEBUG : message);
  endif;

  Return;
end-proc;

///
/// Logger_Info - Enregistre un message d'information
///
/// @param message Message à enregistrer
///
dcl-proc Logger_Info export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_INFO;
    writeLog(LOG_PREFIX_INFO : message);
  endif;
end-proc;

///
/// Logger_Warning - Enregistre un message d'avertissement
///
/// @param message Message à enregistrer
///
dcl-proc Logger_Warning export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_WARNING;
    writeLog(LOG_PREFIX_WARNING : message);
  endif;
end-proc;

///
/// Logger_Error - Enregistre un message d'erreur
///
/// @param message Message à enregistrer
///
dcl-proc Logger_Error export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_ERROR;
    writeLog(LOG_PREFIX_ERROR : message);
  endif;
end-proc;

///
/// Logger_Fatal - Enregistre un message d'erreur fatale
///
/// @param message Message à enregistrer
///
dcl-proc Logger_Fatal export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_FATAL;
    writeLog(LOG_PREFIX_FATAL : message);
  endif;
end-proc;

///
/// Logger_SetLevel - Définit le niveau de journalisation
///
/// @param level Niveau de journalisation (0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=FATAL)
///
dcl-proc Logger_SetLevel export;
  dcl-pi *n;
    level int(10) const;
  end-pi;

  if level >= LOG_LEVEL_DEBUG and level <= LOG_LEVEL_FATAL;
    gLogLevel = level;
  endif;
end-proc;

///
/// Logger_GetLevel - Retourne le niveau de journalisation actuel
///
/// @return Niveau de journalisation actuel
///
dcl-proc Logger_GetLevel export;
  dcl-pi *n int(10) end-pi;

  return gLogLevel;
end-proc;

//*************************************************************
// Procédures internes
//*************************************************************

///
/// writeLog - Écrit un message dans le journal système
///
/// @param prefix Préfixe du message (niveau de log)
/// @param message Message à écrire
///
dcl-proc writeLog;
  dcl-pi *n;
    prefix varchar(10) const;
    message varchar(512) const;
  end-pi;

  dcl-s timestamp char(26);
  dcl-s fullMessage varchar(1024);
  dcl-s cmd varchar(1024);

  // Obtenir le timestamp
  timestamp = %char(%timestamp());

  // Construire le message complet
  fullMessage = %trim(timestamp) + ' [' + %trim(prefix) + '] ' + %trim(message);

  // Écrire dans stdout (journal système)
  Qp0zLprintf(%trim(fullMessage) + NEWLINE);

  // Optionnel: Écrire dans QSYSOPR (décommenté si nécessaire)
  // cmd = 'SNDMSG MSG(''' + %trim(message) + ''') TOUSR(QSYSOPR)';
  // system(%trim(cmd));
end-proc;

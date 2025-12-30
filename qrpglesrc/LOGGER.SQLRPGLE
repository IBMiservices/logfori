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

dcl-pr QUSRJOBI extproc('QUSRJOBI');
  rcvvar char(32767) options(*varsize);
  rcvlen int(10) const;
  format char(8) const;
  jobnam char(26) const;
  jobint char(16) const;
error char(32767) options(*varsize:*nopass);
end-pr;

//*************************************************************
// Implémentation des procédures
//*************************************************************

///
/// LoggerInit - Initialise le service de journalisation
///
dcl-proc LoggerInit export;
  if not gInitialized;
    gInitialized = *on;
    gLogLevel = LOG_LEVEL_INFO;
    // Ne pas logger ici pour éviter la récursion pendant l'initialisation
  endif;

  Return;
end-proc;

///
/// LoggerInitFromJobLog - Initialise et synchronise avec le paramètre LOG du job
///
/// Cette procédure initialise le service et configure automatiquement le niveau
/// de journalisation en fonction du paramètre LOG du job IBM i courant.
///
/// Mapping LOG -> LOGFORI:
/// - LOG(4 00 *SECLVL) -> DEBUG (tous les détails)
/// - LOG(4 00 *MSG) avec sévérité 00-19 -> INFO
/// - LOG(* 20-29 *) -> WARNING
/// - LOG(* 30-39 *) -> ERROR
/// - LOG(* 40+ *) -> FATAL
///
dcl-proc LoggerInitFromJobLog export;
  dcl-ds jobi0400 qualified;
    bytesRet int(10);
    bytesAvail int(10);
    jobName char(10);
    userName char(10);
    jobNumber char(6);
    jobIntID char(16);
    jobStatus char(10);
    jobType char(1);
    jobSubtype char(1);
    reserved char(2);
    *n char(56); // Filler jusqu'à offset 116
    logLevel int(10) pos(117);
    logSeverity int(10) pos(121);
    logText char(10) pos(125);
  end-ds;

  dcl-ds errorDS qualified;
    bytesProvided int(10) inz(0);
  end-ds;

  // Initialiser le service
  if not gInitialized;
    gInitialized = *on;
    gLogLevel = LOG_LEVEL_INFO; // Valeur par défaut
  endif;

  // Récupérer les infos du job courant
  QUSRJOBI(jobi0400 : %size(jobi0400) : 'JOBI0400' : '*' : '' : errorDS);

  // Mapper le niveau LOG IBM i vers LOGFORI
  select;
    // LOG(4 00 *SECLVL) = DEBUG
    when jobi0400.logLevel = 4 and jobi0400.logSeverity = 0
         and %trim(jobi0400.logText) = '*SECLVL';
      gLogLevel = LOG_LEVEL_DEBUG;

    // Sévérité 0-19 = INFO
    when jobi0400.logSeverity < 20;
      gLogLevel = LOG_LEVEL_INFO;

    // Sévérité 20-29 = WARNING
    when jobi0400.logSeverity < 30;
      gLogLevel = LOG_LEVEL_WARNING;

    // Sévérité 30-39 = ERROR
    when jobi0400.logSeverity < 40;
      gLogLevel = LOG_LEVEL_ERROR;

    // Sévérité 40+ = FATAL
    other;
      gLogLevel = LOG_LEVEL_FATAL;
  endsl;

  Return;
end-proc;

///
/// LoggerTerm - Termine le service de journalisation
///
dcl-proc LoggerTerm export;
  if gInitialized;
    // Logger le message avant de désactiver le service
    writeLog(LOG_PREFIX_INFO : 'Service de journalisation terminé');
    gInitialized = *off;
  endif;

  Return;
end-proc;

///
/// LoggerDebug - Enregistre un message de débogage
///
/// @param message Message à enregistrer
///
dcl-proc LoggerDebug export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_DEBUG;
    writeLog(LOG_PREFIX_DEBUG : message);
  endif;

  Return;
end-proc;

///
/// LoggerInfo - Enregistre un message d'information
///
/// @param message Message à enregistrer
///
dcl-proc LoggerInfo export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_INFO;
    writeLog(LOG_PREFIX_INFO : message);
  endif;

  Return;
end-proc;

///
/// LoggerWarning - Enregistre un message d'avertissement
///
/// @param message Message à enregistrer
///
dcl-proc LoggerWarning export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_WARNING;
    writeLog(LOG_PREFIX_WARNING : message);
  endif;

  Return;
end-proc;

///
/// LoggerError - Enregistre un message d'erreur
///
/// @param message Message à enregistrer
///
dcl-proc LoggerError export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_ERROR;
    writeLog(LOG_PREFIX_ERROR : message);
  endif;

  Return;
end-proc;

///
/// LoggerFatal - Enregistre un message d'erreur fatale
///
/// @param message Message à enregistrer
///
dcl-proc LoggerFatal export;
  dcl-pi *n;
    message varchar(512) const;
  end-pi;

  if gLogLevel <= LOG_LEVEL_FATAL;
    writeLog(LOG_PREFIX_FATAL : message);
  endif;

  Return;
end-proc;

///
/// LoggerSetLevel - Définit le niveau de journalisation
///
/// @param level Niveau de journalisation (0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=FATAL)
///
dcl-proc LoggerSetLevel export;
  dcl-pi *n;
    level int(10) const;
  end-pi;

  if level >= LOG_LEVEL_DEBUG and level <= LOG_LEVEL_FATAL;
    gLogLevel = level;
  endif;

  Return;
end-proc;

///
/// LoggerGetLevel - Retourne le niveau de journalisation actuel
///
/// @return Niveau de journalisation actuel
///
dcl-proc LoggerGetLevel export;
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

  // Écrire dans le joblog (journal système)
  Qp0zLprintf(%trim(fullMessage) + NEWLINE);

  // Optionnel: Écrire dans QSYSOPR (décommenté si nécessaire)
  // cmd = 'SNDMSG MSG(''' + %trim(message) + ''') TOUSR(QSYSOPR)';
  // system(%trim(cmd));

  Return;
end-proc;

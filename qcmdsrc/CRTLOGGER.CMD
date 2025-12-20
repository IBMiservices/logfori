/*==================================================================*/
/* CRTLOGGER - Commande de création du programme de service LOGGER */
/*                                                                  */
/* Cette commande compile le module LOGGER et crée le programme    */
/* de service correspondant.                                       */
/*                                                                  */
/* Usage: CALL QCMD/CRTLOGGER                                      */
/*        ou depuis PASE: system "CALL QCMD/CRTLOGGER"             */
/*==================================================================*/

CMD        PROMPT('Créer programme service LOGGER')

PARM       KWD(LIB) TYPE(*NAME) LEN(10) DFT(QGPL) +
           PROMPT('Bibliothèque cible')

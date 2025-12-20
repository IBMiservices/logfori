#!/bin/bash
###############################################################################
# build.sh - Script de compilation pour LOGFORI
#
# Ce script compile le service LOGGER sur IBM i depuis PASE.
#
# Usage: ./build.sh [LIBRARY]
#
# Paramètres:
#   LIBRARY  - Bibliothèque cible (défaut: QGPL)
#
# Exemples:
#   ./build.sh           # Compile dans QGPL
#   ./build.sh MYLIB     # Compile dans MYLIB
###############################################################################

# Bibliothèque cible
LIB=${1:-QGPL}

# Répertoire de base
BASEDIR=$(dirname "$0")

echo "=========================================="
echo "Compilation du service LOGGER"
echo "Bibliothèque cible: $LIB"
echo "=========================================="

# Vérifier que la bibliothèque existe
if ! system "CHKOBJ OBJ($LIB) OBJTYPE(*LIB)" > /dev/null 2>&1; then
    echo "Erreur: La bibliothèque $LIB n'existe pas"
    echo "Création de la bibliothèque..."
    system "CRTLIB LIB($LIB) TEXT('Bibliothèque pour LOGFORI')" || exit 1
fi

# Étape 1: Compiler le module LOGGER
echo ""
echo "Étape 1: Compilation du module LOGGER..."
system "CRTSQLRPGI OBJ($LIB/LOGGER) \
        SRCSTMF('$BASEDIR/qrpglesrc/LOGGER.SQLRPGLE') \
        OBJTYPE(*MODULE) \
        DBGVIEW(*SOURCE) \
        REPLACE(*YES) \
        COMMIT(*NONE) \
        COMPILEOPT('TGTRLS(*CURRENT)')" || {
    echo "Erreur lors de la compilation du module LOGGER"
    exit 1
}
echo "✓ Module LOGGER compilé"

# Étape 2: Créer le programme de service
echo ""
echo "Étape 2: Création du programme de service LOGGER..."
system "CRTSRVPGM SRVPGM($LIB/LOGGER) \
        MODULE($LIB/LOGGER) \
        EXPORT(*SRCFILE) \
        SRCSTMF('$BASEDIR/qsrvsrc/LOGGER.BND') \
        BNDSRVPGM(*NONE) \
        ACTGRP(*CALLER) \
        DETAIL(*BASIC) \
        STGMDL(*INHERIT) \
        REPLACE(*YES) \
        TEXT('Service de journalisation')" || {
    echo "Erreur lors de la création du programme de service"
    exit 1
}
echo "✓ Programme de service LOGGER créé"

# Étape 3: Créer ou mettre à jour le répertoire de liaison
echo ""
echo "Étape 3: Configuration du répertoire de liaison..."
if ! system "CHKOBJ OBJ($LIB/LOGGER) OBJTYPE(*BNDDIR)" > /dev/null 2>&1; then
    system "CRTBNDDIR BNDDIR($LIB/LOGGER)" || {
        echo "Erreur lors de la création du répertoire de liaison"
        exit 1
    }
    echo "✓ Répertoire de liaison LOGGER créé"
else
    echo "✓ Répertoire de liaison LOGGER existe déjà"
fi

# Ajouter le programme de service au répertoire de liaison
system "ADDBNDDIRE BNDDIR($LIB/LOGGER) OBJ(($LIB/LOGGER *SRVPGM))" 2>/dev/null
echo "✓ Programme de service ajouté au répertoire de liaison"

echo ""
echo "=========================================="
echo "✓ Compilation terminée avec succès!"
echo "=========================================="
echo ""
echo "Pour utiliser le service LOGGER:"
echo "  1. Ajouter BNDDIR('$LIB/LOGGER') dans votre programme"
echo "  2. Inclure /copy qrpglesrc,loggerapi"
echo "  3. Appeler Logger_Init() au début"
echo "  4. Utiliser Logger_Info(), Logger_Error(), etc."
echo "  5. Appeler Logger_Term() à la fin"
echo ""
echo "Pour tester:"
echo "  ./build_test.sh $LIB"
echo ""

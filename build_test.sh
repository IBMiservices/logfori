#!/bin/bash
###############################################################################
# build_test.sh - Script de compilation du programme de test
#
# Ce script compile le programme de test TESTLOGGER.
#
# Usage: ./build_test.sh [LIBRARY]
#
# Paramètres:
#   LIBRARY  - Bibliothèque cible (défaut: QGPL)
###############################################################################

# Bibliothèque cible
LIB=${1:-QGPL}

# Répertoire de base
BASEDIR=$(dirname "$0")

echo "=========================================="
echo "Compilation du programme de test TESTLOGGER"
echo "Bibliothèque: $LIB"
echo "=========================================="

# Vérifier que le programme de service existe
if ! system "CHKOBJ OBJ($LIB/LOGGER) OBJTYPE(*SRVPGM)" > /dev/null 2>&1; then
    echo "Erreur: Le programme de service $LIB/LOGGER n'existe pas"
    echo "Veuillez d'abord exécuter: ./build.sh $LIB"
    exit 1
fi

# Compiler le programme de test
echo ""
echo "Compilation du programme TESTLOGGER..."
system "CRTSQLRPGI OBJ($LIB/TESTLOGGER) \
        SRCSTMF('$BASEDIR/qrpglesrc/TESTLOGGER.SQLRPGLE') \
        OBJTYPE(*PGM) \
        DBGVIEW(*SOURCE) \
        REPLACE(*YES) \
        COMMIT(*NONE) \
        BNDSRVPGM($LIB/LOGGER)" || {
    echo "Erreur lors de la compilation du programme de test"
    exit 1
}
echo "✓ Programme TESTLOGGER compilé"

echo ""
echo "=========================================="
echo "✓ Compilation terminée avec succès!"
echo "=========================================="
echo ""
echo "Pour exécuter le test:"
echo "  system \"CALL $LIB/TESTLOGGER\""
echo ""
echo "Ou depuis la ligne de commande IBM i:"
echo "  CALL $LIB/TESTLOGGER"
echo ""

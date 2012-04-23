#!/bin/bash

set -o errexit
set -x

# Optionally configure which programs to use:
if [ "$HADDOCK" == "" ];
then HADDOCK=`which haddock`
fi
if [ "$CABAL" == "" ];
then CABAL=`which cabal`
fi
if [ "$GHC" == "" ];
then GHC=`which ghc`
fi

# Make sure you have ALL the Accelerate modules:
git submodule update --init --recursive

# This installs all the monad par packages and other packages with which it is co-developed.

$CABAL install --force-reinstalls --with-ghc=$GHC $*     \
  Deques/CAS/ Deques/AbstractDeque/ Deques/MichaelScott/ Deques/ChaseLev/ Deques/MegaDeque/ \
  accelerate/ accelerate/accelerate-io/ \
  abstract-par/ monad-par-extras/ monad-par/ meta-par/  \
  RPC/ meta-par-dist-tcp/             \
  abstract-par-accelerate/ meta-par-accelerate/ 

# meta-par-cuda/
# accelerate-backend-kit

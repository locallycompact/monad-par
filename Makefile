
# This provides some convenient shorthands for installing many cabal packages.

# It is essentially a more compact way of bundling what would be a
# handful of shell scripts.

# --------------------------------------------------------------------------------
# Set up some Variables
# --------------------------------------------------------------------------------

OUR_PKGS= abstract-par/ monad-par-extras/ monad-par/ meta-par/  \
  abstract-par-accelerate/ meta-par-accelerate/

# This isn't really meant to be distributed:
# meta-par-cuda/

DEQUE_PKGS= Deques/CAS/ Deques/AbstractDeque/ Deques/MichaelScott/ \
  Deques/ChaseLev/ Deques/MegaDeque/ 

NETWORK_PKGS=   RPC/ meta-par-dist-tcp/ \
  distributed-process/network-transport \
  distributed-process/network-transport-pipes/

ACC_PKGS= accelerate/ accelerate/accelerate-io/
ACC_GPU_PKGS= accelerate/accelerate-cuda/ 

ALL_PKGS= ${DEQUE_PKGS} ${ACC_PKGS} ${OUR_PKGS} 
ALL_NETWORK_PKGS = ${ALL_PKGS} ${NETWORK_PKGS}
ALL_GPU_PKGS = ${ALL_PKGS} ${ACC_GPU_PKGS}

# if [ "$HADDOCK" == "" ];
# then HADDOCK=`which haddock`
# fi
# if [ "$CABAL" == "" ];
# then CABAL=`which cabal`
# fi
# if [ "$GHC" == "" ];
# then GHC=`which ghc`
# fi

ifeq ($(GHC),)
  GHC=`which ghc`
endif 

ifeq ($(HADDOCK),)
  HADDOCK= "$(HOME)/.cabal/bin/haddock"
endif

ifeq ($(CABAL),)
  CABAL= cabal
endif

CABAL_INSTALL= ${CABAL} install --with-ghc=${GHC} ${CABAL_ARGS}

# --------------------------------------------------------------------------------
# Installation
# --------------------------------------------------------------------------------

install: install-all

# Issue a single big cabal command to install everything.
install-with-tests:
	${CABAL_INSTALL} ${OUR_PKGS} --enable-tests

install-all:
	${CABAL_INSTALL} ${OUR_PKGS}


mega-install:
	${CABAL_INSTALL} ${ALL_PKGS} 

mega-install-gpu:
	${CABAL_INSTALL} -fcuda ${ALL_GPU_PKGS} 


# --------------------------------------------------------------------------------
# Testing 
# --------------------------------------------------------------------------------

# Running a full test uses cabal-dev to sandbox the build.
test: 
	$(MAKE) mega-install CABAL='cabal-dev' CABAL_ARGS='--enable-tests --disable-documentation'
# SANDBOX=`pwd`/cabal-dev
# pushd monad-par
# cabal-dev -s $SANDBOX configure --with-ghc=$GHC --with-ghc-pkg=$GHC_PKG --enable-tests
# cabal-dev -s $SANDBOX build
# cabal-dev -s $SANDBOX test --test-options='--jxml=dist/test/$test-suite.xml'
# popd


# --------------------------------------------------------------------------------
# Documentation 
# --------------------------------------------------------------------------------

doc:
	rm -rf docs
	mkdir docs
        # Link EVERYTHING to Haddock:
	${CABAL_INSTALL} ${ALL_PKGS} --enable-documentation \
           --haddock-html-location='http://hackage.haskell.org/packages/archive/$pkg/latest/doc/html' --with-haddock=${HADDOCK}
	mv */dist/doc/html/* docs/
	mv ./Deques/*/dist/doc/html/* docs/
	mv ./accelerate/*/dist/doc/html/* docs/

# TODO: If we also moved over all the otherd docs from the global and
# user DBs we could create a complete documentation collection on this
# website and no longer depend on hackage:
install-doc:
	rsync -vrplt docs/ ~/.hyplan/haddock/
	cd ~/.hyplan/haddock/
	makedirindex > index.html
	chmod ugo+rX -R .

# --------------------------------------------------------------------------------

clean:

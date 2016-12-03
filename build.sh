#!/usr/bin/env bash

CUR_DIR=`pwd`
INTER_DIR=${CUR_DIR}/Obj
BIN_DIR=${CUR_DIR}/Bin

ARCHS=( \
	i386 	\
	x86_64 	\
	armv7 	\
	armv7s 	\
	arm64 	\
)

SDKS=( \
	iphonesimulator	\
	iphonesimulator	\
	iphoneos		\
	iphoneos		\
	iphoneos		\
)

# remove intermediate dirs
rm -rf ${INTER_DIR}
mkdir -p ${INTER_DIR}

# remove unversal bin dirs
rm -rf ${BIN_DIR}
mkdir -p ${BIN_DIR}

# build all architectures
for i in ${!ARCHS[@]}; do

	sdk=${SDKS[i]}
	arch=${ARCHS[i]}

	echo "Building ${arch}..."

	export DESTDIR="${INTER_DIR}/${arch}"
	export CFLAGS="-Ofast -mios-version-min=7.0"
	export LDFLAGS="-flto"
	export CC="xcrun -sdk ${sdk} clang -arch ${arch}"

	mkdir -p ${DESTDIR}

	make clean && make -j8 lib && make install

done

# make universal libs
libNames=($(basename $(find ${INTER_DIR}/${ARCHS[0]} -name *.a)))

for i in ${!libNames[@]}; do

	lib=${libNames[i]}
	echo "Making Universal for lib for '${lib}'"

	allLibs=$(find ${INTER_DIR} -name ${lib})
	
	xcrun lipo -create ${allLibs} -o ${BIN_DIR}/${lib}

done

exit 0

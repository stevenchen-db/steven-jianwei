# platform
UNAME             := $(shell uname)

# cc code
SRC                = src
BUILD              = build
CXXFLAGS          += -std=c++17 -Wall -Werror -O2 -DNDEBUG

CXXFLAGS          += -I${INSTALL_SP}/include
LDFLAGS           += -L${INSTALL_SP}/lib -lsentencepiece
LDFLAGS           += -Wl,-rpath,${INSTALL_SP}/lib

# sentencepiece related
SRC_SP             = third_party/sentencepiece
BUILD_SP           = build_sentencepiece
INSTALL_SP         = install_sentencepiece

# demo related
INSTALL_DEMO_MODEL =  install_demo_model

LIB_PATH_SET       = DYLD_LIBRARY_PATH=${INSTALL_SP}/lib LD_LIBRARY_PATH=${INSTALL_SP}/lib

# clang-format
CLANG_EXTS         = -iname *.h -o -iname *.c -o -name *.cc
CLANG_FMT          = clang-format -i --style=file
FMT                = sh -c 'find "$$@" ${CLANG_EXTS} | xargs ${CLANG_FMT}' sh
FMT_FOLDERS        = src

# ==================================================================================================
# actions

# ---------
# bootstrap
bootstrap: bootstrap_sentencepiece bootstrap_demo_model

bootstrap_sentencepiece: ${INSTALL_SP}/lib/libsentencepiece.a

${INSTALL_SP}/lib/libsentencepiece.a:
	git submodule update --init && \
	mkdir -p ${BUILD_SP} && \
	cd ${BUILD_SP} && \
	cmake ../${SRC_SP} && \
	make -j && \
	cmake --install . --prefix ../${INSTALL_SP}

bootstrap_demo_model: bootstrap_sentencepiece ${INSTALL_DEMO_MODEL}/shakespeare.model
	echo "Hello" | ${LIB_PATH_SET} ${INSTALL_SP}/bin/spm_encode --model=${INSTALL_DEMO_MODEL}/shakespeare.model --output_format=piece

${INSTALL_DEMO_MODEL}/data.txt:
	mkdir -p ${INSTALL_DEMO_MODEL} && \
	wget https://raw.githubusercontent.com/brunoklein99/deep-learning-notes/master/shakespeare.txt -O ${INSTALL_DEMO_MODEL}/data.txt

${INSTALL_DEMO_MODEL}/shakespeare.model: ${INSTALL_DEMO_MODEL}/data.txt
	${LIB_PATH_SET} ${INSTALL_SP}/bin/spm_train --input=${INSTALL_DEMO_MODEL}/data.txt --model_prefix=${INSTALL_DEMO_MODEL}/shakespeare --vocab_size=8000  --model_type=bpe


# ---------
# cc
compile: encoder

.PHONY: compile

encoder: ${BUILD}/encoder

run_encoder: ${BUILD}/encoder
	$<

.PHONY: encoder run_encoder

${BUILD}/encoder: ${SRC}/encoder_main.cc | ${BUILD}
	${CXX} -o $@ ${CXXFLAGS} -DMODEL_FILE='"${INSTALL_DEMO_MODEL}/shakespeare.model"' $< ${LDFLAGS}

${BUILD}:
	mkdir -p ${BUILD}

# ------
# format
fmt:
	${FMT} ${FMT_FOLDERS}

clean:
	rm -rf ${BUILD} ${BUILD_SP}

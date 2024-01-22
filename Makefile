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
INSTALL_DEMO_MODEL = install_demo_model

LIB_PATH_SET       = DYLD_LIBRARY_PATH=${INSTALL_SP}/lib LD_LIBRARY_PATH=${INSTALL_SP}/lib

# mistral related
INSTALL_MISTRAL    = install_mistral

# clang-format
CLANG_EXTS         = -iname *.h -o -iname *.c -o -name *.cc
CLANG_FMT          = clang-format -i --style=file
FMT                = sh -c 'find "$$@" ${CLANG_EXTS} | xargs ${CLANG_FMT}' sh
FMT_FOLDERS        = src

# ==================================================================================================
# actions

# ---------
# bootstrap
bootstrap: bootstrap_sentencepiece bootstrap_demo_model bootstrap_mistral

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

bootstrap_mistral: ${INSTALL_MISTRAL}/tokenizer.model

${INSTALL_MISTRAL}/tokenizer.model:
	mkdir -p ${INSTALL_MISTRAL} && \
	wget https://github.com/stevenchen-db/steven-jianwei/releases/download/v0.0.1/tokenizer.model -O ${INSTALL_MISTRAL}/tokenizer.model

# ---------
# cc
compile: encoder_demo encoder_mistral

.PHONY: compile

encoder_demo: ${BUILD}/encoder_demo

run_encoder_demo: ${BUILD}/encoder_demo
	$<

encoder_mistral: ${BUILD}/encoder_mistral

run_encoder_mistral: ${BUILD}/encoder_mistral
	$<

.PHONY: encoder_demo run_encoder_demo encoder_mistral run_encoder_mistral

${BUILD}/encoder_demo: ${SRC}/encoder_main.cc | ${BUILD}
	${CXX} -o $@ ${CXXFLAGS} -DMODEL_FILE='"${INSTALL_DEMO_MODEL}/shakespeare.model"' $< ${LDFLAGS}

${BUILD}/encoder_mistral: ${SRC}/encoder_main.cc | ${BUILD}
	${CXX} -o $@ ${CXXFLAGS} -DMODEL_FILE='"${INSTALL_MISTRAL}/tokenizer.model"' $< ${LDFLAGS}


${BUILD}:
	mkdir -p ${BUILD}

# ------
# format
fmt:
	${FMT} ${FMT_FOLDERS}

clean:
	rm -rf ${BUILD} ${BUILD_SP}

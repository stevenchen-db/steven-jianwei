# sentencepiece related
SRC_SP             = third_party/sentencepiece
BUILD_SP           = build_sentencepiece
INSTALL_SP         = install_sentencepiece

# demo related
INSTALL_DEMO_MODEL =  install_demo_model

LIB_PATH_SET       = DYLD_LIBRARY_PATH=${INSTALL_SP}/lib LD_LIBRARY_PATH=${INSTALL_SP}/lib

# actions
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

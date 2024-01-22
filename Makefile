SRC_SP     = third_party/sentencepiece
BUILD_SP   = build_sentencepiece
INSTALL_SP = install_sentencepiece

bootstrap: bootstrap_sentencepiece

bootstrap_sentencepiece:
	git submodule update --init && \
	mkdir -p ${BUILD_SP} && \
	cd ${BUILD_SP} && \
	cmake ../${SRC_SP} && \
	make -j && \
	cmake --install . --prefix ../${INSTALL_SP}

ATHENA_MODULE_NAME=Athena

ENABLE_ATHENA?=${ENABLE_ALL_MODULES_BY_DEFAULT}

ifeq (${ENABLE_ATHENA},YES)
modules+=${ATHENA_MODULE_NAME}
endif

ATHENA_SOURCE_DIR=${FORWARDER_SOURCE_DIR}/${ATHENA_MODULE_NAME}
ATHENA_BUILD_DIR=${DISTILLERY_BUILD_DIR}/${ATHENA_MODULE_NAME}
ATHENA_GIT_CONFIG=${ATHENA_SOURCE_DIR}/.git/config

ATHENA_GIT_REPOSITORY=https://${DISTILLERY_GITHUB_SERVER}/${DISTILLERY_GITHUB_USER}/Athena
ATHENA_GIT_UPSTREAM_REPOSITORY=${DISTILLERY_GITHUB_UPSTREAM_URL}/Athena

modules_dir+=${ATHENA_SOURCE_DIR}

# init target, called to initialize the module, normally this would do a git
# checkout or download the source/binary from somewhere
Athena.init: ${ATHENA_GIT_CONFIG}
	@echo ${ATHENA_SOURCE_DIR}
	@cd ${ATHENA_SOURCE_DIR} && git pull && git fetch --all

${ATHENA_GIT_CONFIG}:
	@git clone ${ATHENA_GIT_REPOSITORY} ${ATHENA_SOURCE_DIR}
	@cd ${ATHENA_SOURCE_DIR} && git remote add \
	  ${DISTILLERY_GITHUB_UPSTREAM_NAME} ${ATHENA_GIT_UPSTREAM_REPOSITORY}

Athena.build: ${ATHENA_BUILD_DIR}/Makefile
	${MAKE} ${MAKE_BUILD_FLAGS} -C ${ATHENA_BUILD_DIR} 

${ATHENA_BUILD_DIR}/Makefile: ${ATHENA_SOURCE_DIR}/CMakeLists.txt ${DISTILLERY_STAMP}
		mkdir -p ${ATHENA_BUILD_DIR}
	    cd ${ATHENA_BUILD_DIR}; \
			cmake ${ATHENA_SOURCE_DIR} \
			${CMAKE_BUILD_TYPE_FLAG} \
		    -DCMAKE_INSTALL_PREFIX=${DISTILLERY_INSTALL_DIR}

Athena.install: ${ATHENA_BUILD_DIR}/Makefile
	@${MAKE} ${MAKE_BUILD_FLAGS} -C ${ATHENA_BUILD_DIR} install

Athena.clean: ${ATHENA_BUILD_DIR}/Makefile
	@${MAKE} ${MAKE_BUILD_FLAGS} -C ${ATHENA_BUILD_DIR} clean

Athena.distclean: 
	@rm -rf ${ATHENA_BUILD_DIR}

Athena.check: ${ATHENA_BUILD_DIR}/Makefile
	@${MAKE} ${MAKE_BUILD_FLAGS} -C ${ATHENA_BUILD_DIR} test ${CMAKE_MAKE_TEST_ARGS} 

# The CMakeLists.txt (or any other dependency for a Makefile) is created when a
# repository is cloned. We do not know what the user wants at this point so
# give the user an error.
${ATHENA_SOURCE_DIR}/CMakeLists.txt: 
	    @$(MAKE) distillery.checkout.error

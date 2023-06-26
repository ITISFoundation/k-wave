FROM nvidia/cudagl:11.2.2-runtime-ubuntu20.04 as base
#
#  USAGE:
#     cd services/k-wave
#     docker build -f Dockerfile -t k-wave:prod --target production ../../
#     docker run k-wave:prod
#

LABEL maintainer=elisabettai

# simcore-user uid=8004(${SC_USER_NAME}) gid=8004(${SC_USER_NAME}) groups=8004(${SC_USER_NAME})
ENV SC_USER_ID 8004
ENV SC_USER_NAME scu
RUN adduser --uid ${SC_USER_ID} --disabled-password --gecos "" --shell /bin/sh --home /home/${SC_USER_NAME} ${SC_USER_NAME}

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    jq \
    && rm --recursive --force /var/lib/apt/lists/*

# -------------------------- Build stage -------------------
# Installs build/package management tools and third party dependencies
#
# + /build             WORKDIR
#

FROM base as build

ENV SC_BUILD_TARGET build

ARG KWAVE_PASSWORD
ARG KWAVE_LOGIN
# ------------------------------------------------------------------------------------
# build dependencies shall be installed
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
 unzip \
 gcc \
 curl \
&& rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------------------------
# Download binaries (get authentication cookie to login to http://www.k-wave.org/download.php and download the file with the cookie)
# Note, you need to have a valid login and export credentials as env. variables

WORKDIR /build


RUN curl --cookie-jar cookie.txt --form password=$KWAVE_PASSWORD --form user_login=$KWAVE_LOGIN http://www.k-wave.org/forum/bb-login.php && \
 curl -L -b cookie.txt http://www.k-wave.org/getfile.php?id=117 -o kwave.zip && \
  unzip kwave.zip && \
  rm kwave.zip cookie.txt
# ------------------------------------------------------------------------------------


# defines the output of the build
RUN mkdir --parents /build/bin
# copy src code: There's none for the moment
#COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} src/k_wave src/k_wave
# ------------------------------------------------------------------------------------
#TODO:
# uncomment and adapt if build steps are necessary. For now, we use the compiled executable
RUN cp -R /build/kspaceFirstOrder-CUDA /build/bin
# ------------------------------------------------------------------------------------

# --------------------------Production stage -------------------
# Final cleanup up to reduce image size and startup setup
# Runs as ${SC_USER_NAME} (non-root user)
#
#  + /home/${SC_USER_NAME}     $HOME = WORKDIR
#    + k_wave [${SC_USER_NAME}:${SC_USER_NAME}]
#    + docker [${SC_USER_NAME}:${SC_USER_NAME}]
#    + service.cli [${SC_USER_NAME}:${SC_USER_NAME}]
#
FROM base as production

ENV SC_BUILD_TARGET production
ENV SC_BOOT_MODE production


ENV INPUT_FOLDER="/input" \
    OUTPUT_FOLDER="/output"


WORKDIR /home/${SC_USER_NAME}

# ------------------------------------------------------------------------------------
# uncomment and adapt to install runtime dependencies
RUN apt-get update \
 && apt-get -y install --no-install-recommends \
    libgomp1 \
 && rm -rf /var/lib/apt/lists/*
# ------------------------------------------------------------------------------------

# copy docker bootup scripts
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} docker/custom/*.sh docker/
# copy simcore service cli
COPY --chown=${SC_USER_NAME}:${SC_USER_NAME} service.cli/ service.cli/
# necessary to be able to call run directly without sh in front
ENV PATH="/home/${SC_USER_NAME}/service.cli:${PATH}"

# copy binaries from build
COPY --from=build --chown=${SC_USER_NAME}:${SC_USER_NAME} /build/bin k_wave
RUN chmod +x k_wave/*

ENTRYPOINT [ "/bin/sh", "docker/entrypoint.sh", "/bin/sh", "-c" ]
CMD ["run"]

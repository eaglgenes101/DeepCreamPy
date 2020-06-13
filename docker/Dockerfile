FROM tensorflow/tensorflow:1.15.0rc2-gpu-py3 as dcp_phase0

RUN set -ex; \
    echo "Updating apt package lists."; \
    apt update && \
    echo "Done."

RUN set -ex; \
    echo "Upgrading apt packages."; \
    apt full-upgrade -y && \
    apt install jq -y && \
    echo "Done."

RUN set -ex; \
    echo "Cleaning up."; \
    apt autoremove -y && \
    apt clean && \
    apt autoclean && \
    echo "Done."


# ============================================================================ #

FROM dcp_phase0 as dcp_phase1

WORKDIR /opt

COPY settings.json /opt
RUN set -ex; \
    echo "Downloading required packages."; \
    apt install --no-install-recommends -y \
        $(jq -r '.packages|join(" ")' settings.json) && \
    echo "Done."

RUN set -ex; \
    echo "Cleaning up."; \
    apt clean && \
    apt autoclean && \
    echo "Done."

RUN set -ex; \
    echo "Deep cleaning leftover APT files."; \
    rm -rf /var/lib/apt/lists/*; \
    rm -f /var/cache/apt/archives/*.deb \
        /var/cache/apt/archives/partial/*.deb \
        /var/cache/apt/*.bin; \
    echo "Done.";


# ============================================================================ #

FROM dcp_phase1 as dcp_phase2

WORKDIR /opt

COPY gd.sh /usr/local/bin
RUN  chmod 755 /usr/local/bin/gd.sh

RUN set -ex; \
    cd /opt; \
    mkdir -p models; \
    MODELS_GOOGLE_ID="$(jq -r '.models_id' settings.json)"; \
    echo "Downloading the models from the Google Drive"; \
    gd.sh "${MODELS_GOOGLE_ID}" model.zip && \
    echo "Done."

RUN set -ex; \
    echo "Extracting."; \
    unzip model.zip  && \
    echo "Done."

RUN set -ex; \
    echo "Moving model.h5 to models folder."; \
    mv model.h5 models && \
    echo "Done."


# ============================================================================ #

FROM dcp_phase2 as dcp_phase3

WORKDIR /opt

RUN set -ex; \
    cd /opt; \
    TARBALL_URL="https://api.github.com/repos/$( \
        jq \
            -r '[.dcp.user, .dcp.repo, "tarball", .dcp.branch] | join("/")' \
            settings.json \
    )"; \
    FOLDER_REGEX="$(jq -r '[.dcp.user, .dcp.repo, "[a-f0-9]+"] | join("-")')"
    SED_XFORM="/^${FOLDER_REGEX}/DeepCreamPy"
    echo "Downloading the tarballed DCP source at: ${TARBALL_URL}"; \
    curl -sL "${TARBALL_URL}" | tar xz && \
    echo "Done."
    
RUN set -ex; \
    cd /opt; \
    DCP_FOLDER="$(ls -1rt)"; \
    echo "Checking out the DCP Branch: ${BRANCH}"; \
    git checkout "${BRANCH}" && \
    echo "Done."

RUN ln -s /opt/models /opt/DeepCreamPy/models


# ============================================================================ #

FROM dcp_phase3 as dcp_phase4

WORKDIR /opt

COPY docker_requirements.txt /tmp
RUN set -ex; \
    echo "Installing the pip requirements."; \
    pip3 install -v -r /tmp/requirements-docker.txt && \
    echo "Done."

RUN set -ex; \
    echo "Cleaning up."; \
    rm -rf /tmp/* /var/tmp/*; \
    find /usr/lib/python3 -name __pycache__ | xargs rm -r; \
    rm -rf /root/.[acpw]*;


# ============================================================================ #

FROM dcp_phase4 as dcp_phase5

VOLUME [ "/opt/DeepCreamPy/decensor_input", "decensor_input_original", "/opt/DeepCreamPy/decensor_output" ]

WORKDIR /opt/DeepCreamPy

ENTRYPOINT [ "/usr/bin/python3", "/opt/DeepCreamPy/decensor.py" ]



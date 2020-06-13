FROM tensorflow/tensorflow:1.15.0rc2-gpu-py3 as dcp_phase0

ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
    echo "Updating apt package lists."; \
    apt update && \
    echo "Done."

# Install tzdata. Just rip that bandaid off right now.
RUN set -ex; \
    echo "Installing tzdata to get it out of the way."; \
    apt install -y tzdata && \
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

FROM dcp_phase1 as dcp_phase2_0

WORKDIR /opt

COPY gd.sh /usr/local/bin
RUN  chmod 755 /usr/local/bin/gd.sh

RUN set -ex; \
    cd /opt; \
    MODELS_GOOGLE_ID="$(jq -r '.models_id' settings.json)"; \
    mkdir -p models; \
    cd models; \
    echo "Downloading the models from the Google Drive"; \
    gd.sh "${MODELS_GOOGLE_ID}" model.zip && \
    echo "Done."

# ---------------------------------------------------------------------------- #

FROM dcp_phase2_0 as dcp_phase2_1

WORKDIR /opt/models

RUN set -ex; \
    cd /opt/models; \
    echo "Extracting."; \
    unzip model.zip  && \
    rm model.zip && \
    echo "Done."

# ---------------------------------------------------------------------------- #

FROM dcp_phase2_1 as dcp_phase2_2

WORKDIR /opt/models

RUN set -ex; \
    cd /opt/models; \
    echo "Moving models to models folder."; \
    MODEL_FOLDER="$(ls -1 | head -n 1)"; \
    cd "${MODEL_FOLDER}" && \
    mv bar .. && \
    mv mosaic .. && \
    cd .. && \
    rm -r "${MODEL_FOLDER}" && \
    echo "Done."

# ---------------------------------------------------------------------------- #

FROM dcp_phase2_2 as dcp_phase2

# ============================================================================ #

FROM dcp_phase2 as dcp_phase3_0

WORKDIR /opt

RUN set -ex; \
    cd /opt; \
    TARBALL_URL="https://api.github.com/repos/$( \
        jq \
            -r '[.dcp.user, .dcp.repo, "tarball", .dcp.branch] | join("/")' \
            settings.json \
    )"; \
    echo "Downloading the tarballed DCP source at: ${TARBALL_URL}"; \
    curl -sL "${TARBALL_URL}" | tar xz && \
    echo "Done."

# ---------------------------------------------------------------------------- #

FROM dcp_phase3_0 as dcp_phase3_1

WORKDIR /opt

RUN set -ex; \
    cd /opt; \
    echo "Renaming extracted DCP source folder to DeepCreamPy"; \
    FOLDER_HINT="$(jq -r '[.dcp.user, .dcp.repo] | join("-")' settings.json)"; \
    FOLDER_NAME="$(ls -1rt | grep ${FOLDER_HINT})"; \
    mv "${FOLDER_NAME}" DeepCreamPy && \
    echo "Done."    

RUN rm -r /opt/DeepCreamPy/models
RUN ln -s /opt/models /opt/DeepCreamPy/models

# ---------------------------------------------------------------------------- #

FROM dcp_phase3_1 as dcp_phase3

# ============================================================================ #

FROM dcp_phase3 as dcp_phase4_0

WORKDIR /opt

COPY requirements-docker.txt /tmp
RUN set -ex; \
    echo "Installing the pip requirements."; \
    pip3 install -v -r /tmp/requirements-docker.txt && \
    echo "Done."

# ---------------------------------------------------------------------------- #

FROM dcp_phase4_0 as dcp_phase4_1

WORKDIR /opt

RUN set -ex; \
    echo "Cleaning up."; \
    rm -rf /tmp/* /var/tmp/*; \
    find /usr/lib/python3 -name __pycache__ | xargs rm -r; \
    rm -rf /root/.[acpw]*;

# ---------------------------------------------------------------------------- #

FROM dcp_phase4_1 as dcp_phase4

# ============================================================================ #

FROM dcp_phase4 as dcp_phase5

VOLUME [ "/opt/DeepCreamPy/decensor_input", "decensor_input_original", "/opt/DeepCreamPy/decensor_output" ]

WORKDIR /opt/DeepCreamPy

# ENTRYPOINT [ "/usr/bin/python3", "/opt/DeepCreamPy/decensor.py" ]
ENTRYPOINT [ "/bin/bash" ]


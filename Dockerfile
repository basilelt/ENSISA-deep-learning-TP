FROM python:3.9-slim AS tf-builder

ARG TF_VERSION=v2.8.0
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    default-jdk \
    pkg-config \
    unzip \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools wheel numpy==1.22.4

# Bazelisk selects a Bazel version compatible with TensorFlow's .bazelversion file.
RUN if [ "$TARGETARCH" = "arm64" ]; then \
    BAZELISK_ASSET="bazelisk-linux-arm64"; \
    else \
    BAZELISK_ASSET="bazelisk-linux-amd64"; \
    fi && \
    curl -fsSL -o /usr/local/bin/bazel \
    "https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/${BAZELISK_ASSET}" && \
    chmod +x /usr/local/bin/bazel

WORKDIR /src
RUN git clone --depth 1 --branch ${TF_VERSION} https://github.com/tensorflow/tensorflow.git
RUN find /src/tensorflow \( -name 'WORKSPACE' -o -name '*.bzl' -o -name '*.bazelrc' \) -type f -print0 | \
    xargs -0 sed -i \
    -e 's#https://storage.googleapis.com/mirror.tensorflow.org/#https://#g' \
    -e 's#https://mirror.bazel.build/#https://#g'

WORKDIR /src/tensorflow
ENV TF_NEED_CUDA=0 \
    TF_NEED_ROCM=0 \
    TF_NEED_MPI=0 \
    TF_SET_ANDROID_WORKSPACE=0 \
    CC_OPT_FLAGS="-Wno-sign-compare" \
    PYTHON_BIN_PATH=/usr/local/bin/python3

# Non-interactive configure using defaults suitable for CPU-only build.
RUN yes "" | ./configure

RUN bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
RUN ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tf_pkg

FROM python:3.9-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip

COPY --from=tf-builder /tmp/tf_pkg /tmp/tf_pkg
RUN pip install --no-cache-dir /tmp/tf_pkg/tensorflow-2.8.0-*.whl && rm -rf /tmp/tf_pkg

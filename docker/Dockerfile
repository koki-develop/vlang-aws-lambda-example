FROM public.ecr.aws/lambda/provided:al2023 AS vlang

RUN dnf install -y \
      git \
      make \
      gcc \
      libatomic

# NOTE: Temporary workaround for `library 'atomic' not found` error when running `v install` (as of V 0.4.9)
RUN ln -s /usr/lib64/libatomic.so.1 /usr/lib64/libatomic.so

# Install vlang
# See: https://github.com/vlang/v#installing-v-from-source
RUN git clone --depth=1 https://github.com/vlang/v /vlang/v \
    && cd /vlang/v \
    && make \
    && ./v symlink

# ---

FROM vlang AS builder

COPY v.mod v.mod
RUN v install

COPY . .
RUN v -prod -o ./main .

# ---

FROM public.ecr.aws/lambda/provided:al2023

COPY --from=builder /var/task/main ${LAMBDA_TASK_ROOT}/main
COPY docker/bootstrap ${LAMBDA_RUNTIME_DIR}/bootstrap

CMD ["main"]

FROM public.ecr.aws/lambda/provided:al2023 AS vlang

RUN dnf install -y \
      git \
      make \
      gcc \
      libatomic

# Install vlang
# See: https://github.com/vlang/v#installing-v-from-source
RUN git clone --depth=1 https://github.com/vlang/v /vlang/v \
    && cd /vlang/v \
    && make \
    && ./v symlink

# ---

FROM vlang AS builder

COPY . .
RUN v -prod -o ./main .

# ---

FROM public.ecr.aws/lambda/provided:al2023

COPY --from=builder /var/task/main ${LAMBDA_TASK_ROOT}/main
COPY docker/bootstrap ${LAMBDA_RUNTIME_DIR}/bootstrap

CMD ["main"]

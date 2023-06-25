FROM rust:1.70.0-slim-bullseye AS build
WORKDIR /build
RUN apt-get update && \
    apt-get install -y apt-utils pkg-config libssl-dev --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*
COPY . .
RUN cargo build --release

FROM debian:12.0-slim AS prod
RUN apt-get update  && \
    apt-get install -y ca-certificates --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*
WORKDIR /app
COPY --from=build /build/target/release/webhookstuff .
RUN adduser --disabled-password appuser
USER appuser
ENV RUST_LOG=info
ENTRYPOINT [ "./webhookstuff" ]
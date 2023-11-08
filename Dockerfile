FROM ghcr.io/gleam-lang/gleam:v0.32.2-erlang-alpine

# copy litefs binary
COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs

# Add project code
COPY . /source

# Compile the Gleam application
RUN cd /source \
  && apk add --no-cache gcc build-base ca-certificates fuse3 sqlite \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && cd .. && rm -r /source \
  && apk del gcc build-base

COPY litefs.yml /etc/litefs.yml

# Run
WORKDIR /app
ENTRYPOINT litefs mount

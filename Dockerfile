FROM ghcr.io/gleam-lang/gleam:v0.31.0-erlang-alpine

# Add project code
COPY . /build/

# Compile the Gleam application
RUN cd /build \
  && apk add gcc build-base \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build \
  && apk del gcc build-base

# Run the application
WORKDIR /app
ENTRYPOINT ["entrypoint.sh"]
CMD ["run"]

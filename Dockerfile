FROM ghcr.io/gleam-lang/gleam:v0.31.0-erlang-alpine

# Add project code
COPY . /source

# Compile the Gleam application
RUN cd /source \
  && apk add --no-cache gcc build-base \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && cd .. && rm -r /source \
  && apk del gcc build-base

# Run
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
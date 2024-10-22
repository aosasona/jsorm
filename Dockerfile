FROM ghcr.io/gleam-lang/gleam:v1.5.1-erlang-alpine


# Add project code
COPY . /source

# Compile the Gleam application
RUN cd /source \
  && apk add --no-cache gcc build-base ca-certificates fuse3 sqlite \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && cd .. && rm -r /source \
  && apk del gcc build-base

# Run
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

# Node builder for Tailwind and TS compilation
FROM node:22-alpine AS build

WORKDIR /app
COPY package.json pnpm-lock.yaml ./

RUN npm install -g pnpm \
  && pnpm install

COPY . .
RUN pnpm build:assets

# Final image
FROM ghcr.io/gleam-lang/gleam:v1.13.0-erlang-alpine AS runtime

COPY --from=build /app /source

RUN cd /source \
  && apk add --no-cache gcc build-base ca-certificates fuse3 sqlite \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && cd .. && rm -r /source \
  && apk del gcc build-base

WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

# syntax=docker/dockerfile:1

FROM hexpm/elixir:1.15.7-erlang-26.2.1-debian-bookworm-20240130 AS build

ENV MIX_ENV=prod
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential git npm nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

COPY assets assets
RUN mix assets.setup
RUN mix assets.deploy

COPY lib lib
COPY priv priv
RUN mix compile
RUN mix release

FROM debian:bookworm-slim AS app

ENV LANG=C.UTF-8
ENV MIX_ENV=prod
ENV PHX_SERVER=true

RUN apt-get update && \
    apt-get install -y --no-install-recommends libssl3 libstdc++6 libncursesw6 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/_build/prod/rel/doc_rocker ./

EXPOSE 4000

CMD ["bin/doc_rocker", "start"]

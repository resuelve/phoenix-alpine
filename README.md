# Phoenix Alpine

A docker image based on alpine with everything you need to develop phoenix apps, with tools like nodejs and wkhtmltopdf out of the box.

Erlang and elixir are installed with asdf so new versions are easy to manage and upgrade.

## Use cases:

### Run your app in dev mode with docker compose
Just add a `docker-compose.yml` to your project with something like this, and start developing!

```yaml
version: '3.7'

volumes:
  deps:
  builds:
  node_modules:

services:
  phx:
    image: resuelve/phoenix-alpine:1.5.4
    ports:
      - ${HTTP_PORT:-4000}:${HTTP_PORT:-4000}
    volumes:
      - ./:/app/src
      - deps:/app/src/deps
      - builds:/app/src/_build
      - node_modules:/app/src/assets/node_modules
    depends_on:
      - postgres
    environment:
      - MIX_ENV=${ENV:-dev}
      - POSTGRES_URL=ecto://postgres:postgres@postgres/your_app_name_${ENV:-dev}
      - HTTP_PORT=${HTTP_PORT:-4000}
    working_dir: /app/src

  postgres:
    image: postgres:9.6
    ports:
      - ${DATABASE_EXTERNAL_PORT:-5432}:5432
    environment:
      POSTGRES_HOST_AUTH_METHOD: "trust"
```

Then execute your app with simple commands:

```bash
# Commands to set-up your app
docker-compose run --rm phx sh -c "mix ecto.create"
docker-compose run --rm phx sh -c "mix ecto.migrate"
docker-compose run --rm phx sh -c "cd assets/node_modules && npm install"

# Start your server
docker-compose run --service-ports phx iex --sname your_app -S mix phx.server

# To run tests
ENV=test docker-compose run --rm phx sh -c "mix test"
```

### Build a production image and deploy with alpine
Use this base image to build everything you need before deploy. Since the image is based on alpine, you can use a clean alpine image to deploy your app.

```dockerfile
FROM resuelve/phoenix-alpine:1.5.4
LABEL maintainer="Awesome dev <awesome@resuelve.mx>"
ARG GOOGLE_SECRET_JSON
ARG GH_TOKEN
ENV MIX_ENV=prod

COPY ./src /app/src
WORKDIR /app/src
RUN mkdir -p /run/secrets
RUN echo $GOOGLE_SECRET_JSON > /run/secrets/google_credentials
RUN mix deps.get && mix deps.compile
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest && mix distillery.release --no-tar --env=prod

FROM alpine:3.12
RUN apk --no-cache add -U musl musl-dev ncurses-libs libressl3.1-libcrypto bash
COPY --from=0 /app/src/_build/prod/rel /rel

WORKDIR /rel
CMD /rel/elixir_app/bin/elixir_app foreground
```
You can build, deploy or run your image locally, or using some CI tool like Drone to deploy wherever you want, everything with a unique Dockerfile

```bash
# Build with required envs.

docker build --build-arg GOOGLE_SECRET_JSON=$GOOGLE_SECRET_JSON --build-arg GH_TOKEN=${GH_TOKEN} --tag resuelve/elixir_app:latest .
# Test and run your image on localhost

docker run -it --env-file .env.prod -p 4080:4080 resuelve/elixir_app:latest

# Deploy your image to dockerhub
docker push resuelve/elixir_app:latest
```
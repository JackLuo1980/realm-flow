FROM golang:1.24-alpine AS build

WORKDIR /src

RUN apk add --no-cache git build-base

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o /out/paneld ./cmd/paneld

FROM alpine:3.21

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app
COPY --from=build /out/paneld /usr/local/bin/paneld

ENV APP_ENV=production \
    HTTP_PORT=6365 \
    DATABASE_URL=file:/data/realmflow.db?_foreign_keys=on \
    JWT_SECRET=realmflow-production-secret \
    JWT_ISSUER=realmflow

VOLUME ["/data"]
EXPOSE 6365

ENTRYPOINT ["/usr/local/bin/paneld"]

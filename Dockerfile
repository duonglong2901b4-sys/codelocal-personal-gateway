FROM golang:1.23-bookworm AS build
WORKDIR /src
COPY src.part.* /tmp/
RUN cat /tmp/src.part.* | base64 -d | tar -xz -C /src
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/codelocal-personal-gateway ./cmd/codelocal-personal-gateway

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app
COPY --from=build /out/codelocal-personal-gateway /app/codelocal-personal-gateway
ENV CODELOCAL_GATEWAY_STATE=/data/gateway-state.json
EXPOSE 8080
VOLUME ["/data"]
ENTRYPOINT ["/app/codelocal-personal-gateway"]
CMD ["--listen",":8080"]

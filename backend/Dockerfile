FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o cronos-backend .

FROM alpine:3.19

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/cronos-backend .
COPY --from=builder /app/.env .

RUN mkdir -p uploads

EXPOSE 8080

CMD ["./cronos-backend"]

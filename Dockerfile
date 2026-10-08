FROM alpine:3.19

# Install required tools
RUN apk add --no-cache bash coreutils iputils bind-tools netcat-openbsd

WORKDIR /app

# Copy application and helper scripts
COPY app/ /app/app/
COPY scripts/ /app/scripts/
COPY tests/ /app/tests/

# Set executable permissions
RUN chmod +x /app/app/*.sh /app/scripts/*.sh /app/tests/*.sh

ENTRYPOINT ["/app/app/app.sh"]
CMD ["help"]

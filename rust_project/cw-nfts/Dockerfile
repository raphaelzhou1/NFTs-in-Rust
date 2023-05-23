# Start with the base image
FROM cosmwasm/workspace-optimizer:0.12.11

# Change to root user to have necessary permissions
USER root

# Create the directories that you'll be using as volumes
RUN mkdir -p /code/target/release && touch /code/target/release/.cargo-lock && chown -R root:root /code/target/release/.cargo-lock && chmod 755 /code/target/release/.cargo-lock

# Set the environment variable
ENV RUST_BACKTRACE full

# Switch back to a non-root user if your base image uses one
USER 1001

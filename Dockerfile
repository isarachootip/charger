# Stage 1: Build the Flutter app
FROM ubuntu:20.04 AS build-env

# Install dependencies needed for Flutter
RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils zip libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Clone the Flutter repository
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set Flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor to trigger download of Dart SDK and other tools
RUN flutter doctor

# Set the working directory
WORKDIR /app

# Copy the app files to the container
COPY . .

# Get dependencies and build the web app
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve the app using Nginx
FROM nginx:alpine

# Copy the build output from the builder stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

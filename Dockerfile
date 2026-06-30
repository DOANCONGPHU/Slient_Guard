# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release --no-tree-shake-icons

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html




CMD sh -c "echo 'events {} http { include /etc/nginx/mime.types; server { listen '\"$PORT\"'; root /usr/share/nginx/html; index index.html; location / { try_files \$uri \$uri/ /index.html; } } }' > /etc/nginx/nginx.conf && nginx -g 'daemon off;'"

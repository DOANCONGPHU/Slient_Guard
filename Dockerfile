# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release --no-tree-shake-icons

# Stage 2: Serve with nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html


ENV PORT=8080
EXPOSE 8080

CMD sh -c "sed -i 's/listen 80/listen '\"$PORT\"'/' /etc/nginx/nginx.conf && nginx -g 'daemon off;'"

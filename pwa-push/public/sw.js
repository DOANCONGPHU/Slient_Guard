// Service Worker - chạy ngầm để nhận push kể cả khi đóng app

self.addEventListener('push', function(event) {
  let data = { title: 'Thông báo mới', body: 'Bạn có tin nhắn mới' };

  if (event.data) {
    try { data = JSON.parse(event.data.text()); } catch(e) {}
  }

  // BẮT BUỘC phải gọi showNotification - iOS hủy subscription nếu không có
  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/logo.png',
      badge: '/logo.png',
      vibrate: [200, 100, 200],
      data: { url: self.location.origin }
    })
  );
});

self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window' }).then(function(clientList) {
      for (const client of clientList) {
        if (client.url === '/' && 'focus' in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow('/');
    })
  );
});

self.addEventListener('install', e => e.waitUntil(self.skipWaiting()));
self.addEventListener('activate', e => e.waitUntil(self.clients.claim()));

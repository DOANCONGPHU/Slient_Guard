importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: "AIzaSyCfhqgVNzm0p15W31Rb4ZzC_POKN5SxMDc",
  authDomain: "silentguard-8d104.firebaseapp.com",
  projectId: "silentguard-8d104",
  storageBucket: "silentguard-8d104.firebasestorage.app",
  messagingSenderId: "804956207376",
  appId: "1:804956207376:web:2404eceac2e78302570d95",
  measurementId: "G-7791DWBG6K"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message received: ', payload);

  const data = payload.data || {};
  const notification = payload.notification || {};
  const notificationTitle = notification.title || data.title || 'SilentGuard';
  const notificationOptions = {
    body: notification.body || data.body || '',
    icon: '/icons/Icon-192.png',
    data: data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

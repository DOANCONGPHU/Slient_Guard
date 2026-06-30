importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

// Điền các thông số Firebase Firebase Config của bạn vào đây (Lấy trong Project Settings > General)
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
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

// Lắng nghe thông báo khi ứng dụng chạy ngầm (Background)
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Nhận thông báo ngầm: ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png' // Đường dẫn đến icon của bạn
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
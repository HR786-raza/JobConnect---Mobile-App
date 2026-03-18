// Give the service worker access to Firebase Messaging.
// Note that you can only use Firebase Messaging here. Other Firebase libraries
// are not available in the service worker.
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// REPLACE WITH YOUR ACTUAL FIREBASE CONFIGURATION
firebase.initializeApp({
  apiKey: "AIzaSyDgZLmq3iKO6T-H0XRb3NYFgRail7KXyTI",
  authDomain: "jobconnect-12.firebaseapp.com",
  projectId: "jobconnect-12",
  storageBucket: "jobconnect-12.firebasestorage.app",
  messagingSenderId: "406743820372",
  appId: "1:406743820372:web:609254f42027bec3cc65c1",
  measurementId: "G-1FPEYYKJRR"
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'JobConnect';
  const notificationOptions = {
    body: payload.notification?.body || 'New notification',
    icon: '/icons/icon-192.png',
    badge: '/icons/icon-72.png',
    data: payload.data,
    actions: payload.data?.actions || []
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', function(event) {
  console.log('Notification click: ', event.notification);
  
  event.notification.close();
  
  event.waitUntil(
    clients.matchAll({
      type: 'window',
      includeUncontrolled: true
    }).then(function(clientList) {
      // Check if there's already a window open
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      // If not, open a new window
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
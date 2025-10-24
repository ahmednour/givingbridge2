importScripts(
  "https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyDJ9ACaziNQ6uwQBSiAvorKG8WqO8BRHsk",
  authDomain: "giving-bridge.firebaseapp.com",
  projectId: "giving-bridge",
  storageBucket: "giving-bridge.firebasestorage.app",
  messagingSenderId: "828798718567",
  appId: "1:828798718567:web:162c926c3af58852bebac2",
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log("Background message received:", payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});

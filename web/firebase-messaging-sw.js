importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
apiKey: "AIzaSyCIkAsZdKa6jPVnBv2Dly3T02-XZgj3sEA",
  authDomain: "gograb-87d87.firebaseapp.com",
  databaseURL: "https://gograb-87d87-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "gograb-87d87",
  storageBucket: "gograb-87d87.firebasestorage.app",
  messagingSenderId: "167391621913",
  appId: "1:167391621913:web:7a85472e8cf436284bcb88"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});
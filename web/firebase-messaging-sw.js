importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
 apiKey: "AIzaSyCLRIsZgBnF3M4H9jvjXi1tftYsd74hBwc",
        authDomain: "alabtechdemos.firebaseapp.com",
        databaseURL: "https://alabtechdemos-default-rtdb.firebaseio.com",
        projectId: "alabtechdemos",
        storageBucket: "alabtechdemos.firebasestorage.app",
        messagingSenderId: "591429626414",
        appId: "1:591429626414:web:1a1fb782f5b85074290dbf",
        measurementId: "G-K3RQ31D4HD"
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
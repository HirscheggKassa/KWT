// ================================
// KASSA APP - SERVICE WORKER
// ================================
// Hinweis: Service Worker hat keinen Zugriff auf APP_CONFIG,
// daher werden die Werte hier nochmal definiert.
// Bei Änderungen in config.js auch hier anpassen!

const CACHE_NAME = 'kassa-app-v1';  // Muss mit APP_CONFIG.app.cache_name übereinstimmen
const BASE_PATH = '/';              // Muss mit APP_CONFIG.app.start_url übereinstimmen

const urlsToCache = [
    BASE_PATH,
    BASE_PATH + 'index.html',
    BASE_PATH + 'styles.css',
    BASE_PATH + 'config.js',
    BASE_PATH + 'app.js',
    BASE_PATH + 'manifest.json',
    'https://unpkg.com/dexie@3.2.4/dist/dexie.min.js',
    'https://fonts.googleapis.com/css2?family=Archivo:wght@300;400;500;700&family=Crimson+Pro:wght@400;600;700&display=swap'
];

// Install Event - Cache Resources
self.addEventListener('install', event => {
    console.log('Service Worker: Installing...');
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('Service Worker: Caching files');
                return cache.addAll(urlsToCache);
            })
            .then(() => self.skipWaiting())
    );
});

// Activate Event - Clean Up Old Caches
self.addEventListener('activate', event => {
    console.log('Service Worker: Activating...');
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('Service Worker: Deleting old cache:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        }).then(() => self.clients.claim())
    );
});

// Fetch Event - Serve from Cache, Fallback to Network
self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request)
            .then(response => {
                if (response) {
                    return response;
                }

                const fetchRequest = event.request.clone();

                return fetch(fetchRequest).then(response => {
                    if (!response || response.status !== 200 || response.type !== 'basic') {
                        return response;
                    }

                    const responseToCache = response.clone();

                    caches.open(CACHE_NAME)
                        .then(cache => {
                            cache.put(event.request, responseToCache);
                        });

                    return response;
                });
            }).catch(() => {
                return caches.match(BASE_PATH + 'index.html');
            })
    );
});

// Background Sync
self.addEventListener('sync', event => {
    if (event.tag === 'sync-buchungen') {
        console.log('Service Worker: Syncing buchungen...');
    }
});

// Push Notifications
self.addEventListener('push', event => {
    const data = event.data ? event.data.json() : {};
    const options = {
        body: data.body || 'Neue Benachrichtigung',
        icon: BASE_PATH + 'assets/icon-192.png',
        badge: BASE_PATH + 'assets/icon-72.png',
        vibrate: [200, 100, 200]
    };

    event.waitUntil(
        self.registration.showNotification(data.title || 'Kassa', options)
    );
});

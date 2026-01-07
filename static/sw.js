const CACHE_NAME = 'doc-rocker-v1';
const STATIC_ASSETS = [
  '/',
  '/manifest.json',
  '/icon-192x192.png',
  '/icon-512x512.png',
  '/favicon.png'
];

// Install event - cache static assets
self.addEventListener('install', (event) => {
  console.log('[SW] Install event');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Caching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
      .then(() => {
        // Force the waiting service worker to become the active service worker
        return self.skipWaiting();
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[SW] Activate event');
  event.waitUntil(
    caches.keys()
      .then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME) {
              console.log('[SW] Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        // Ensure the new service worker takes control immediately
        return self.clients.claim();
      })
  );
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', (event) => {
  // Only handle GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Skip cross-origin requests
  if (!event.request.url.startsWith(self.location.origin)) {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version if available
        if (response) {
          return response;
        }

        // Otherwise, fetch from network
        return fetch(event.request)
          .then((response) => {
            // Check if we received a valid response
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Clone the response for caching
            const responseToCache = response.clone();

            // Cache successful responses for static assets
            if (event.request.url.includes('.css') || 
                event.request.url.includes('.js') || 
                event.request.url.includes('.png') || 
                event.request.url.includes('.jpg') || 
                event.request.url.includes('.webp') ||
                event.request.url.includes('/favicon.')) {
              caches.open(CACHE_NAME)
                .then((cache) => {
                  cache.put(event.request, responseToCache);
                });
            }

            return response;
          })
          .catch(() => {
            // If network fails and we're requesting the main page, return a basic offline page
            if (event.request.mode === 'navigate') {
              return new Response(`
                <!DOCTYPE html>
                <html>
                <head>
                  <title>Doc-Rocker - Offline</title>
                  <meta name="viewport" content="width=device-width, initial-scale=1">
                  <style>
                    body { 
                      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                      display: flex;
                      justify-content: center;
                      align-items: center;
                      height: 100vh;
                      margin: 0;
                      background: #f8fafc;
                      color: #1e293b;
                    }
                    .offline-message {
                      text-align: center;
                      padding: 2rem;
                      max-width: 400px;
                    }
                    h1 { color: #4361ee; margin-bottom: 1rem; }
                    p { margin-bottom: 1.5rem; }
                    button {
                      background: #4361ee;
                      color: white;
                      border: none;
                      padding: 0.75rem 1.5rem;
                      border-radius: 0.5rem;
                      cursor: pointer;
                      font-size: 1rem;
                    }
                    button:hover { background: #3f37c9; }
                  </style>
                </head>
                <body>
                  <div class="offline-message">
                    <h1>📚 Doc-Rocker</h1>
                    <p>You're currently offline. Please check your internet connection and try again.</p>
                    <button onclick="window.location.reload()">Try Again</button>
                  </div>
                </body>
                </html>
              `, {
                headers: { 'Content-Type': 'text/html' }
              });
            }
          });
      })
  );
}); 
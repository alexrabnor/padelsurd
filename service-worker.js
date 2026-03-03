const CACHE = 'iksurd-v1';
const FILES = [
  '/',
  '/index.html',
  '/config.js',
  '/surd-logo.png'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)));
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(r => r || fetch(e.request))
  );
});

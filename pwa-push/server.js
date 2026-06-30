const express = require('express');
const webpush = require('web-push');
const path = require('path');

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const VAPID_PUBLIC  = 'BEC0Qj9ZpeALiG9Ma_kaBEm_v4obLRmp4Ep3i4oMw2-Qb-zCwoTYJ42UCSUAq1dzIUOtmqExjgXoYRCjQKyrkPM';
const VAPID_PRIVATE = 'FIdV7Vl6iPofZMEpR8sRfNKIinZ5UrPMTVAx-w_da5I';

webpush.setVapidDetails('mailto:demo@example.com', VAPID_PUBLIC, VAPID_PRIVATE);

// Lưu subscriptions trong bộ nhớ (demo - production dùng DB)
const subscriptions = new Map();

app.get('/vapidPublicKey', (req, res) => {
  res.json({ publicKey: VAPID_PUBLIC });
});

app.post('/subscribe', (req, res) => {
  const sub = req.body;
  const id = sub.endpoint.split('/').pop().slice(-8);
  subscriptions.set(id, sub);
  console.log('Thiết bị mới subscribe:', id, '| Tổng:', subscriptions.size);
  res.json({ ok: true, id });
});

app.post('/send', async (req, res) => {
  const { title, body } = req.body;
  const payload = JSON.stringify({ title, body });
  const results = [];

  for (const [id, sub] of subscriptions) {
    try {
      await webpush.sendNotification(sub, payload);
      results.push({ id, ok: true });
    } catch (err) {
      console.error('Lỗi gửi tới', id, err.statusCode);
      if (err.statusCode === 410) subscriptions.delete(id);
      results.push({ id, ok: false, error: err.statusCode });
    }
  }

  res.json({ sent: results.filter(r => r.ok).length, total: subscriptions.size });
});

app.get('/status', (req, res) => {
  res.json({ subscribers: subscriptions.size });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log('Server chạy tại http://localhost:' + PORT));

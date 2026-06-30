# PWA Web Push - Không cần Apple Developer Account

## Chạy local (test trên máy)

```bash
npm install
node server.js
# Mở http://localhost:3000
```

## Deploy miễn phí lên Render.com (cần HTTPS để test trên iPhone)

1. Đẩy code lên GitHub:
   ```bash
   git init
   git add .
   git commit -m "PWA push demo"
   git remote add origin https://github.com/username/pwa-push.git
   git push -u origin main
   ```

2. Vào https://render.com → New → Web Service
3. Connect GitHub repo
4. Cài đặt:
   - Build Command: `npm install`
   - Start Command: `node server.js`
   - Free tier (750h/tháng — đủ dùng)
5. Deploy → lấy URL dạng `https://ten-app.onrender.com`

## Test trên iPhone

1. Mở URL HTTPS trên **Safari** (không dùng Chrome trên iPhone)
2. Nhấn nút Chia sẻ → "Thêm vào màn hình chính"
3. Mở app từ icon vừa tạo (quan trọng!)
4. Nhấn "Bật thông báo" → cho phép
5. Mở tab khác hoặc PC → vào cùng URL → nhấn "Gửi tới tất cả thiết bị"
6. iPhone nhận notification!

## Yêu cầu

- iPhone iOS 16.4 trở lên
- Safari (bắt buộc để Add to Home Screen)
- App phải mở ở chế độ standalone (từ icon màn hình chính)

## Lưu ý production

- Subscriptions hiện lưu trong RAM — khởi động lại server là mất
- Production: dùng Redis hoặc MongoDB để lưu subscriptions
- VAPID keys trong server.js cần giữ bí mật, đưa vào env variable

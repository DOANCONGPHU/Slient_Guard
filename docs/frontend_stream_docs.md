# Hướng dẫn hiển thị Live Stream trên Frontend

Tài liệu này mô tả cách kết nối và hiển thị luồng video (Live Stream) từ Backend lên giao diện Frontend thông qua giao thức WebSocket.

## 1. Cơ chế hoạt động

Hệ thống stream video của chúng ta hoạt động theo cơ chế **MJPEG qua WebSocket**:
- **Edge Device** (Camera) liên tục đẩy (publish) từng khung hình (frame) đã được encode dưới dạng ảnh `.jpg` (raw bytes) lên Backend.
- **Backend Relay** nhận frame và broadcast (phát lại) toàn bộ số frame này tới tất cả các client đang kết nối (subscribe).
- **Frontend** nhận từng frame ảnh dạng Blob và liên tục cập nhật thẻ `<img>` trên HTML để tạo cảm giác video đang chạy (ảo giác khung hình).

## 2. Thông tin Endpoint Backend

> [!IMPORTANT]
> **Giao thức:** Sử dụng `ws://` cho môi trường localhost, và `wss://` cho môi trường production có HTTPS.

- **Endpoint:** `wss://<BACKEND_DOMAIN>/api/streams/{camera_id}/subscribe`
- **Path Parameter:**
  - `{camera_id}`: Là ID của camera hoặc số Serial (device_sn). Frontend cần lấy được thông tin camera này từ API danh sách camera.

## 3. Cách code trên Frontend (JavaScript / React)

### 3.1. Vanilla JavaScript (HTML cơ bản)

Bạn cần 1 thẻ `<img>` trên HTML:
```html
<img id="camera-stream" src="" alt="Live Stream" style="width: 100%; max-width: 640px; border-radius: 8px;" />
```

Và đoạn code JavaScript để kết nối:
```javascript
const cameraId = "IMOU-123456"; // Thay bằng ID thực tế
const wsUrl = `wss://your-backend-domain.com/api/streams/${cameraId}/subscribe`;

const ws = new WebSocket(wsUrl);

// QUAN TRỌNG: Phải set binaryType là 'blob' để nhận dữ liệu nhị phân (ảnh)
ws.binaryType = "blob";

const imgElement = document.getElementById("camera-stream");

ws.onopen = () => {
    console.log("Đã kết nối luồng stream camera:", cameraId);
};

ws.onmessage = (event) => {
    // event.data chính là file ảnh .jpg
    const imageUrl = URL.createObjectURL(event.data);
    
    // Thu hồi URL cũ để tránh rò rỉ bộ nhớ (Memory Leak)
    if (imgElement.src) {
        URL.revokeObjectURL(imgElement.src);
    }
    
    // Cập nhật ảnh mới
    imgElement.src = imageUrl;
};

ws.onerror = (err) => {
    console.error("Lỗi WebSocket:", err);
};

ws.onclose = () => {
    console.log("Đã ngắt kết nối stream");
};
```

### 3.2. Dành cho React.js / Next.js

Nếu Frontend sử dụng React, bạn nên bọc logic WebSocket trong `useEffect` để dễ dàng quản lý việc kết nối và ngắt kết nối khi component unmount.

```jsx
import { useEffect, useRef } from 'react';

export default function CameraStream({ cameraId }) {
  const imgRef = useRef(null);
  const wsRef = useRef(null);

  useEffect(() => {
    if (!cameraId) return;

    // Khởi tạo WebSocket
    const wsUrl = `wss://your-backend-domain.com/api/streams/${cameraId}/subscribe`;
    const ws = new WebSocket(wsUrl);
    ws.binaryType = "blob";
    wsRef.current = ws;

    ws.onmessage = (event) => {
      if (imgRef.current) {
        const imageUrl = URL.createObjectURL(event.data);
        
        // Tránh memory leak
        if (imgRef.current.src) {
          URL.revokeObjectURL(imgRef.current.src);
        }
        imgRef.current.src = imageUrl;
      }
    };

    // Cleanup function: Ngắt kết nối khi rời khỏi trang
    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
      if (imgRef.current && imgRef.current.src) {
        URL.revokeObjectURL(imgRef.current.src);
      }
    };
  }, [cameraId]);

  return (
    <div className="stream-container">
      <img 
        ref={imgRef} 
        alt={`Live stream from ${cameraId}`} 
        className="w-full h-auto rounded-lg shadow-md"
      />
    </div>
  );
}
```

## 4. Các lưu ý cực kỳ quan trọng (Dành cho FE)

> [!WARNING]
> **Tránh Memory Leak (Rò rỉ bộ nhớ):** 
> Mỗi frame gửi về là một ảnh (dung lượng ~50KB). Nếu Frontend dùng `URL.createObjectURL` để tạo ảnh hiển thị mà KHÔNG gọi `URL.revokeObjectURL` để xóa URL ảnh cũ, bộ nhớ RAM của trình duyệt sẽ phình to rất nhanh (mỗi giây tăng 1-2MB) và gây crash (đơ tab trình duyệt). Bắt buộc phải có code thu hồi URL cũ như mẫu ở trên.

> [!TIP]
> **Xử lý mất kết nối (Reconnection):**
> Giao thức WebSocket có thể bị ngắt giữa chừng do mạng không ổn định. Frontend nên cài đặt thêm logic tự động kết nối lại (ví dụ sau 3-5 giây) nếu bắt được sự kiện `ws.onclose`.

> [!NOTE]
> **Luồng Edge chưa chạy thì không có frame:**
> Endpoint subscribe của Backend Relay luôn sẵn sàng kết nối kể cả khi chưa có camera nào phát hình lên. Do đó, nếu connect thành công mà màn hình vẫn trống, Frontend cần hiển thị giao diện chờ (Loading / Waiting for camera...) cho đến khi nhận được event.data đầu tiên.

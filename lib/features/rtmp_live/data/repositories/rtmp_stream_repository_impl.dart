import 'package:mobile/features/devices/data/datasources/imou_cloud_datasource.dart';
import '../../domain/entities/rtmp_stream.dart';
import '../../domain/repositories/rtmp_stream_repository.dart';

// Triển khai RtmpStreamRepository sử dụng Imou Cloud HTTP API.
// Chịu trách nhiệm: kiểm tra camera online, gọi createDeviceRtmpLive,
// chọn URL tốt nhất (HD > SD), và map lỗi Imou sang domain exception.
class RtmpStreamRepositoryImpl implements RtmpStreamRepository {
  const RtmpStreamRepositoryImpl(this._dataSource);

  final ImouCloudDataSource _dataSource;

  // Lấy stream RTMP cho camera
  // Bước 1: Lấy access token từ cache hoặc gọi API
  // Bước 2: Kiểm tra camera online
  // Bước 3: Tạo địa chỉ RTMP live
  // Bước 4: Trả về RtmpStream
  @override
  Future<RtmpStream> getStream(String deviceSn) async {
    // Bước 1: Lấy access token (có cache tự động trong datasource)
    final token = await _dataSource.getAccessToken();

    // Bước 2: Kiểm tra camera có đang online không trước khi tạo session
    final isOnline = await _dataSource.isDeviceOnline(
      accessToken: token.token,
      deviceSn: deviceSn,
    );
    if (!isOnline) {
      // Camera offline — không thể tạo live session
      throw const RtmpStreamException(
        code: 'DEVICE_OFFLINE',
        message: 'Camera đang offline',
      );
    }

    // Bước 3: Tạo địa chỉ RTMP live qua Imou Cloud API
    final info = await _dataSource.createDeviceRtmpLive(
      accessToken: token.token,
      deviceSn: deviceSn,
    );

    // Bước 4: Chọn URL tốt nhất — ưu tiên HD, fallback SD
    final url = info.bestUrl;
    if (url == null || url.isEmpty) {
      throw const RtmpStreamException(
        code: 'NO_RTMP_URL',
        message: 'Imou Cloud không trả về URL RTMP hợp lệ',
      );
    }

    return RtmpStream(
      deviceSn: deviceSn,
      url: url,
      isHd: info.rtmpHd?.isNotEmpty == true,
    );
  }
}

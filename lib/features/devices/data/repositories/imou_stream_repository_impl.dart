import 'package:flutter/foundation.dart';
import 'package:mobile/features/devices/data/datasources/imou_cloud_datasource.dart';
import 'package:mobile/features/devices/data/models/imou_models.dart';
import 'package:mobile/features/devices/domain/repositories/imou_stream_repository.dart';

class ImouStreamRepositoryImpl implements ImouStreamRepository {
  ImouStreamRepositoryImpl(this._dataSource);

  static const _defaultChannelId = '0';
  static const _defaultStreamId = 1;

  final ImouCloudDataSource _dataSource;
  final Map<String, _ImouStreamSession> _activeSessions = {};

  @override
  Future<String> getStreamUrl(String deviceSn) {
    return _getStreamUrl(deviceSn, retriedAfterTokenRefresh: false);
  }

  Future<String> _getStreamUrl(
    String deviceSn, {
    required bool retriedAfterTokenRefresh,
  }) async {
    final normalizedSn = deviceSn.trim();
    if (normalizedSn.isEmpty) {
      throw const ImouApiException(
        'INVALID_DEVICE_SN',
        'Không tìm thấy mã serial của camera.',
      );
    }

    try {
      final accessToken = await _dataSource.getAccessToken();
      final isOnline = await _dataSource.isDeviceOnline(
        accessToken: accessToken.token,
        deviceSn: normalizedSn,
      );
      if (!isOnline) {
        throw const ImouApiException(
          'DEVICE_OFFLINE',
          'Camera is offline or disconnected',
        );
      }

      final bindLiveToken = await _dataSource.bindDeviceLive(
        accessToken: accessToken.token,
        deviceSn: normalizedSn,
        channelId: _defaultChannelId,
        streamId: _defaultStreamId,
      );
      final streamInfo = await _dataSource.getLiveStreamInfo(
        accessToken: accessToken.token,
        deviceSn: normalizedSn,
        channelId: _defaultChannelId,
      );

      final selectedStream = streamInfo.selectedStream;
      final streamUrl = selectedStream?.playbackUrl?.trim();
      if (streamUrl == null || streamUrl.isEmpty) {
        throw const ImouApiException(
          'NO_STREAM_URL',
          'No playable live stream found',
        );
      }

      final liveToken = selectedStream?.liveToken?.trim().isNotEmpty == true
          ? selectedStream!.liveToken!.trim()
          : bindLiveToken?.trim();
      if (liveToken == null || liveToken.isEmpty) {
        throw const ImouApiException(
          'NO_LIVE_TOKEN',
          'Imou Cloud did not return a live token.',
        );
      }

      final session = _ImouStreamSession(
        sessionId: _newSessionId(normalizedSn),
        deviceId: normalizedSn,
        channelId: _defaultChannelId,
        streamId: selectedStream?.streamId ?? _defaultStreamId,
        streamUrl: streamUrl,
        liveToken: liveToken,
        createdAt: DateTime.now(),
      );
      _activeSessions[normalizedSn] = session;
      debugPrint(
        '[ImouStreamRepository] session created deviceId=${_maskDeviceId(normalizedSn)} '
        'sessionId=${session.sessionId} streamId=${session.streamId} '
        'protocol=${Uri.tryParse(streamUrl)?.scheme ?? 'unknown'} '
        'liveToken=${_maskToken(liveToken)}',
      );
      return streamUrl;
    } on ImouApiException catch (error) {
      if (!retriedAfterTokenRefresh && _isTokenExpired(error)) {
        debugPrint('[ImouStreamRepository] token expired, refreshing once');
        _dataSource.clearAccessToken();
        return _getStreamUrl(normalizedSn, retriedAfterTokenRefresh: true);
      }
      rethrow;
    }
  }

  @override
  Future<void> releaseStreamSession(String deviceSn) async {
    final normalizedSn = deviceSn.trim();
    final session = _activeSessions[normalizedSn];
    if (session == null || session.liveToken.trim().isEmpty) return;

    if (_activeSessions[normalizedSn]?.sessionId != session.sessionId) {
      debugPrint(
        '[ImouStreamRepository] skip stale unbind deviceId=${_maskDeviceId(normalizedSn)}',
      );
      return;
    }
    _activeSessions.remove(normalizedSn);

    try {
      final accessToken = await _dataSource.getAccessToken();
      debugPrint(
        '[ImouStreamRepository] unbind reason=screen_closed '
        'deviceId=${_maskDeviceId(session.deviceId)} sessionId=${session.sessionId} '
        'liveToken=${_maskToken(session.liveToken)}',
      );
      await _dataSource.unbindLive(
        accessToken: accessToken.token,
        liveToken: session.liveToken,
      );
    } on Object catch (error) {
      debugPrint('[ImouStreamRepository] unbind failed: $error');
    }
  }

  bool _isTokenExpired(ImouApiException error) {
    final normalized = '${error.code} ${error.message}'.toLowerCase();
    return normalized.contains('token') ||
        normalized.contains('auth') ||
        normalized.contains('expired') ||
        normalized.contains('unauthorized');
  }

  String _newSessionId(String deviceId) {
    return '${deviceId.hashCode.abs()}-${DateTime.now().microsecondsSinceEpoch}';
  }

  String _maskDeviceId(String deviceId) {
    final value = deviceId.trim();
    if (value.length <= 6) return '***';
    return '${value.substring(0, 3)}***${value.substring(value.length - 3)}';
  }

  String _maskToken(String token) {
    final value = token.trim();
    if (value.length <= 8) return '***';
    return '${value.substring(0, 4)}***${value.substring(value.length - 4)}';
  }
}

class _ImouStreamSession {
  const _ImouStreamSession({
    required this.sessionId,
    required this.deviceId,
    required this.channelId,
    required this.streamId,
    required this.streamUrl,
    required this.liveToken,
    required this.createdAt,
  });

  final String sessionId;
  final String deviceId;
  final String channelId;
  final int streamId;
  final String streamUrl;
  final String liveToken;
  final DateTime createdAt;
}

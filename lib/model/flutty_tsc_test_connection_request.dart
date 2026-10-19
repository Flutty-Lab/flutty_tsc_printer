class FluttyTscTestConnectionRequest {
  final String ipAddress;
  final int port;

  FluttyTscTestConnectionRequest({
    required this.ipAddress,
    this.port = 9100,
  });
}

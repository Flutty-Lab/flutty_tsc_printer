/// A request to check that a TSC printer is reachable over TCP/IP.
class FluttyTscTestConnectionRequest {
  /// IPv4 address or hostname of the printer.
  final String ipAddress;

  /// TCP port of the printer's RAW socket (defaults to `9100`).
  final int port;

  /// Creates a connection test request for [ipAddress] on [port].
  FluttyTscTestConnectionRequest({required this.ipAddress, this.port = 9100});
}

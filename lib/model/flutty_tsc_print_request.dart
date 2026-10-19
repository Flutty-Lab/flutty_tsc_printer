/// Base class for all TSC printer commands.
abstract class TscCommand {
  /// Converts the command object to its string representation for the printer.
  String toCommandString();
}

/// Represents a print request to a TSC printer.
class FluttyTscPrintRequest {
  final String ipAddress;
  final int port;
  final List<TscCommand> commands;
  final int writeTimeout;
  final int readTimeout;

  FluttyTscPrintRequest({
    required this.ipAddress,
    required this.commands,
    this.port = 9100,
    this.writeTimeout = 3000,
    this.readTimeout = 2000,
  });

  /// Serializes the list of commands into a single string with Windows-style line endings.
  String get commandsString {
    return '${commands.map((c) => c.toCommandString()).join('\r\n')}\r\n';
  }
}

// --- Concrete Command Classes ---

/// SIZE command
class TscSize implements TscCommand {
  final double width;
  final double height;
  final String unit; // "mm", "inch", "dot"

  TscSize({required this.width, required this.height, this.unit = 'mm'});

  @override
  String toCommandString() {
    return 'SIZE $width $unit, $height $unit';
  }
}

/// GAP command
class TscGap implements TscCommand {
  final double distance;
  final double offset;
  final String unit; // "mm", "inch", "dot"

  TscGap({required this.distance, required this.offset, this.unit = 'mm'});

  @override
  String toCommandString() {
    return 'GAP $distance $unit, $offset $unit';
  }
}

/// AUTODETECT command
class TscAutoDetect implements TscCommand {
  TscAutoDetect();

  @override
  String toCommandString() {
    return 'AUTODETECT';
  }
}

/// CODEPAGE command
class TscCodepage implements TscCommand {
  final String codepage;

  TscCodepage({required this.codepage});

  @override
  String toCommandString() {
    return 'CODEPAGE $codepage';
  }
}

/// GAPDETECT command
class TscGapDetect implements TscCommand {
  TscGapDetect();

  @override
  String toCommandString() {
    return 'GAPDETECT';
  }
}

/// DIRECTION command
class TscDirection implements TscCommand {
  final int direction; // 0 or 1

  TscDirection({required this.direction});

  @override
  String toCommandString() {
    return 'DIRECTION $direction';
  }
}

/// CLS command (Clear buffer)
class TscCls implements TscCommand {
  @override
  String toCommandString() {
    return 'CLS';
  }
}

/// CUT command
class TscCut implements TscCommand {
  @override
  String toCommandString() {
    return 'CUT';
  }
}

/// TEXT command
class TscText implements TscCommand {
  final int x;
  final int y;
  final String font;
  final int rotation;
  final int xMultiplier;
  final int yMultiplier;
  final String content;

  TscText({
    required this.x,
    required this.y,
    required this.font,
    this.rotation = 0,
    this.xMultiplier = 1,
    this.yMultiplier = 1,
    required this.content,
  });

  @override
  String toCommandString() {
    // Content must be enclosed in quotes
    return 'TEXT $x,$y,"$font",$rotation,$xMultiplier,$yMultiplier,"${content.replaceAll('"', '""')}"';
  }
}

/// BARCODE command
class TscBarcode implements TscCommand {
  final int x;
  final int y;
  final String type;
  final int height;
  final int humanReadable;
  final int rotation;
  final int narrow;
  final int wide;
  final String content;

  TscBarcode({
    required this.x,
    required this.y,
    this.type = '128',
    required this.height,
    this.humanReadable = 2,
    this.rotation = 0,
    required this.narrow,
    required this.wide,
    required this.content,
  });

  @override
  String toCommandString() {
    // Content must be enclosed in quotes
    return 'BARCODE $x,$y,"$type",$height,$humanReadable,$rotation,$narrow,$wide,"${content.replaceAll('"', '""')}"';
  }
}

/// PRINT command
class TscPrint implements TscCommand {
  final int quantity;
  final int copies;

  TscPrint({this.quantity = 1, this.copies = 1});

  @override
  String toCommandString() {
    return 'PRINT $quantity,$copies';
  }
}

/// A command to send raw TSPL code.
class TscRaw implements TscCommand {
  final String command;

  TscRaw({required this.command});

  @override
  String toCommandString() {
    return command;
  }
}

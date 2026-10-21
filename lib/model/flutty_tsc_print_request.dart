/// Base class for all TSC printer commands.
abstract class TscCommand {
  /// Converts the command object to its string representation for the printer.
  String toCommandString();
}

/// Represents a print request to a TSC printer.
class FluttyTscPrintRequest {
  /// IPv4 address or hostname of the printer.
  final String ipAddress;

  /// TCP port of the printer's RAW socket (defaults to `9100`).
  final int port;

  /// Ordered list of TSPL commands to send. Must not be empty and should
  /// end with a [TscPrint] command.
  final List<TscCommand> commands;

  /// Milliseconds to wait for the write to complete (defaults to `3000`).
  final int writeTimeout;

  /// Milliseconds of extra grace to wait for a printer response after the
  /// first bytes arrive (defaults to `2000`).
  final int readTimeout;

  /// Creates a print request targeting [ipAddress]:[port] with [commands].
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

/// SIZE command: defines the label size.
class TscSize implements TscCommand {
  /// Label width.
  final double width;

  /// Label height.
  final double height;

  /// Unit of [width] and [height]: `mm`, `inch` or `dot`.
  final String unit;

  /// Creates a SIZE command for a [width] x [height] label in [unit].
  TscSize({required this.width, required this.height, this.unit = 'mm'});

  @override
  String toCommandString() {
    return 'SIZE $width $unit, $height $unit';
  }
}

/// GAP command: defines the gap between two labels.
class TscGap implements TscCommand {
  /// Distance between labels.
  final double distance;

  /// Vertical offset of the gap.
  final double offset;

  /// Unit of [distance] and [offset]: `mm`, `inch` or `dot`.
  final String unit;

  /// Creates a GAP command.
  TscGap({required this.distance, required this.offset, this.unit = 'mm'});

  @override
  String toCommandString() {
    return 'GAP $distance $unit, $offset $unit';
  }
}

/// AUTODETECT command: lets the printer detect the label gap automatically.
class TscAutoDetect implements TscCommand {
  /// Creates an AUTODETECT command.
  TscAutoDetect();

  @override
  String toCommandString() {
    return 'AUTODETECT';
  }
}

/// CODEPAGE command: selects the printer code page.
class TscCodepage implements TscCommand {
  /// Code page name or number, e.g. `UTF-8` or `850`.
  final String codepage;

  /// Creates a CODEPAGE command for [codepage].
  TscCodepage({required this.codepage});

  @override
  String toCommandString() {
    return 'CODEPAGE $codepage';
  }
}

/// GAPDETECT command: triggers a one-shot gap detection.
class TscGapDetect implements TscCommand {
  /// Creates a GAPDETECT command.
  TscGapDetect();

  @override
  String toCommandString() {
    return 'GAPDETECT';
  }
}

/// DIRECTION command: sets the print direction.
class TscDirection implements TscCommand {
  /// `0` or `1`, depending on the label feed orientation.
  final int direction;

  /// Creates a DIRECTION command.
  TscDirection({required this.direction});

  @override
  String toCommandString() {
    return 'DIRECTION $direction';
  }
}

/// CLS command: clears the image buffer.
class TscCls implements TscCommand {
  /// Creates a CLS command.
  TscCls();
  @override
  String toCommandString() {
    return 'CLS';
  }
}

/// CUT command: cuts the label (on printers equipped with a cutter).
class TscCut implements TscCommand {
  /// Creates a CUT command.
  TscCut();
  @override
  String toCommandString() {
    return 'CUT';
  }
}

/// TEXT command: prints a text string.
class TscText implements TscCommand {
  /// X coordinate in dots.
  final int x;

  /// Y coordinate in dots.
  final int y;

  /// Font name or number, e.g. `3`, `TSS24.BF2` or an alphabetic font.
  final String font;

  /// Rotation in degrees: `0`, `90`, `180` or `270`.
  final int rotation;

  /// Horizontal magnification, `1`-`10`.
  final int xMultiplier;

  /// Vertical magnification, `1`-`10`.
  final int yMultiplier;

  /// Text to print. Embedded `"` characters are escaped automatically.
  final String content;

  /// Creates a TEXT command.
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

/// BARCODE command: prints a 1D barcode.
class TscBarcode implements TscCommand {
  /// X coordinate in dots.
  final int x;

  /// Y coordinate in dots.
  final int y;

  /// Barcode symbology, e.g. `128`, `39`, `EAN13` (defaults to `128`).
  final String type;

  /// Barcode height in dots.
  final int height;

  /// Human-readable text position: `0` none, `1` left, `2` center, `3` right.
  final int humanReadable;

  /// Rotation in degrees: `0`, `90`, `180` or `270`.
  final int rotation;

  /// Narrow bar width in dots.
  final int narrow;

  /// Wide bar width in dots.
  final int wide;

  /// Barcode content. Embedded `"` characters are escaped automatically.
  final String content;

  /// Creates a BARCODE command.
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

/// PRINT command: prints the buffered label. Should be the last command
/// of a print request.
class TscPrint implements TscCommand {
  /// Number of label sets to print (defaults to `1`).
  final int quantity;

  /// Number of copies of each label (defaults to `1`).
  final int copies;

  /// Creates a PRINT command.
  TscPrint({this.quantity = 1, this.copies = 1});

  @override
  String toCommandString() {
    return 'PRINT $quantity,$copies';
  }
}

/// A command to send raw TSPL code, for commands not covered by the typed
/// command classes.
class TscRaw implements TscCommand {
  /// The raw TSPL command line, without the trailing `\r\n`.
  final String command;

  /// Creates a raw TSPL command.
  TscRaw({required this.command});

  @override
  String toCommandString() {
    return command;
  }
}

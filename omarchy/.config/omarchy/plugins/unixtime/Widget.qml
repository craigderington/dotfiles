import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Live unix timestamp for the bar, backed by the `waybar-unixtime` Rust binary.
//
// The binary already streams waybar-shaped JSON on an interval and owns the
// display-format state, so this widget holds one long-lived `run` process
// rather than polling `once` on a Timer. A toggle/cycle from a click mutates
// that same shared state, and the next streamed line carries the new format
// back into the label — no refresh signal to plumb, unlike the waybar setup
// this binary was written for.
BarWidget {
  id: root
  moduleName: "unixtime"

  // ~/.cargo/bin is not on the shell process's PATH, so the binary is invoked
  // through a shell that expands $HOME rather than being called by bare name.
  readonly property string binPath: setting("binPath", "$HOME/.cargo/bin/waybar-unixtime")
  readonly property int intervalMs: Math.max(100, setting("intervalMs", 1000))
  readonly property bool notifyOnCopy: setting("notifyOnCopy", true) === true
  // Escape hatch for fine-tuning the label against its neighbours; the label
  // is centre-anchored, so 0 already lines its baseline up with the clock.
  readonly property real baselineNudge: setting("baselineNudge", 0)

  property string label: ""
  property string formatClass: ""

  // Rows are declared rather than scraped so the panel controls its own
  // grouping and wording; `formats` only supplies the values.
  readonly property var timestampRows: [
    { key: "seconds", label: "Seconds" },
    { key: "millis", label: "Milliseconds" },
    { key: "micros", label: "Microseconds" },
    { key: "nanos", label: "Nanoseconds" }
  ]
  readonly property var dateRows: [
    { key: "iso-utc", label: "ISO 8601 UTC" },
    { key: "iso-local", label: "ISO 8601 local" },
    { key: "iso-date", label: "ISO 8601 date" },
    { key: "european", label: "European" },
    { key: "european-short", label: "European (short)" },
    { key: "us", label: "US" },
    { key: "us-short", label: "US (short)" },
    { key: "british", label: "British" },
    { key: "japanese", label: "Japanese" },
    { key: "rfc2822", label: "RFC 2822" },
    { key: "unix-readable", label: "Unix readable" }
  ]

  property var formatValues: ({})

  readonly property string popupFontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property real popupFontSize: Style.font.bodySmall
  readonly property color popupForeground: bar ? bar.foreground : Color.foreground
  readonly property color popupDim: Qt.darker(popupForeground, 1.45)

  function shellArgs(script, args) {
    return ["bash", "-c", script, "unixtime"].concat(args || [])
  }

  function runAction(script, args) {
    actionProc.running = false
    actionProc.command = root.shellArgs(script, args)
    actionProc.running = true
  }

  function toggleFormat() { root.runAction("exec " + root.binPath + " toggle") }
  function cycleFormat(back) {
    root.runAction("exec " + root.binPath + " cycle" + (back ? " --back" : ""))
  }

  // Copied and announced from one capture so the notification always shows the
  // exact value that reached the clipboard, not a second later re-read.
  function copyCurrent() {
    var script = 'v=$(' + root.binPath + ' copy) || exit 1; printf %s "$v" | wl-copy'
    if (root.notifyOnCopy)
      script += '; notify-send -a "Unix timestamp" -t 2000 "Copied" "$v"'
    root.runAction(script)
  }

  function valueFor(key) {
    var map = root.formatValues
    return map && map[key] !== undefined ? map[key] : ""
  }

  function refreshFormats() {
    if (!formatsProc.running) formatsProc.running = true
  }

  // `formats` prints "<key><spaces><value>", plus a trailing `custom:<fmt>`
  // usage line that documents a pattern rather than reporting a value.
  function ingestFormats(text) {
    var map = {}
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      if (!line || line.indexOf("custom:") === 0) continue
      var match = line.match(/^(\S+)\s+(.*)$/)
      if (!match) continue
      map[match[1]] = match[2].replace(/\s+$/, "")
    }
    root.formatValues = map
  }

  function ingest(line) {
    var raw = String(line || "").trim()
    if (raw === "") return
    // A streamed line is one whole JSON object; anything else is skipped
    // rather than allowed to blank a good label.
    try {
      var payload = JSON.parse(raw)
      if (payload && typeof payload.text === "string") root.label = payload.text
      if (payload && typeof payload["class"] === "string") root.formatClass = payload["class"]
    } catch (e) {
      return
    }
  }

  function restartStream() {
    stream.running = false
    stream.running = true
  }

  // `command` is read at spawn, so a settings edit needs an explicit respawn.
  onBinPathChanged: restartStream()
  onIntervalMsChanged: restartStream()

  Process {
    id: stream
    running: true
    command: root.shellArgs('exec ' + root.binPath + ' run --interval "$1"',
                            [String(root.intervalMs)])
    stdout: SplitParser {
      onRead: function(data) { root.ingest(data) }
    }
    onExited: watchdog.restart()
  }

  Process { id: actionProc }

  Process {
    id: formatsProc
    command: root.shellArgs('exec ' + root.binPath + ' formats')
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.ingestFormats(text)
    }
  }

  // The stream is the only source of the label, so a crashed binary would
  // otherwise freeze the bar on a stale number forever.
  Timer {
    id: watchdog
    interval: 2000
    onTriggered: if (!stream.running) root.restartStream()
  }

  Timer {
    interval: 1000
    repeat: true
    running: root.popupOpen
    triggeredOnStart: true
    onTriggered: root.refreshFormats()
  }

  // ---- Hover panel.
  //
  // The bar's own tooltip is a single Text with AlignHCenter, which centres
  // every line independently and so pulls a value table out of column. This
  // is a PopupCard in its passive "hover" mode instead: same card chrome the
  // click panels use, left-aligned, with the value column held to one x.
  property bool popupOpen: false
  readonly property bool hoverActive: button.tooltipHovered || popup.containsMouse

  onHoverActiveChanged: {
    if (hoverActive) {
      closeDelay.stop()
      root.popupOpen = true
    } else {
      closeDelay.restart()
    }
  }

  function openPanel() {
    closeDelay.stop()
    root.popupOpen = true
  }

  function closePanel() {
    closeDelay.stop()
    root.popupOpen = false
  }

  // The card sits a gap below the bar, so the pointer is briefly over neither
  // it nor the button while crossing; closing immediately would flicker.
  Timer {
    id: closeDelay
    interval: 180
    onTriggered: root.popupOpen = false
  }

  // Measured off a constant, not off the live values, so the column does not
  // reflow every second as the digits tick.
  TextMetrics {
    id: labelMetrics
    font.family: root.popupFontFamily
    font.pixelSize: root.popupFontSize
    text: "European (short)"
  }

  TextMetrics {
    id: markMetrics
    font.family: root.popupFontFamily
    font.pixelSize: root.popupFontSize
    text: "✓"
  }

  visible: label !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    width: parent.width
    height: parent.height
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: root.baselineNudge
    bar: root.bar
    text: root.label
    // Matches the clock beside it: same family, same size, so both labels
    // centre to the same baseline in the same slot height.
    fontSize: Style.font.body
    horizontalMargin: 8.75
    verticalPadding: 8.75
    // A vertical bar has no room for a 10+ digit token across its width, so
    // the label is turned to run along the bar instead of being truncated.
    textRotation: root.vertical ? -90 : 0

    onPressed: function(b) {
      if (b === Qt.MiddleButton) root.toggleFormat()
      else if (b === Qt.RightButton) root.cycleFormat(false)
      else root.copyCurrent()
    }

    onWheelMoved: function(delta) { root.cycleFormat(delta < 0) }
  }

  PopupCard {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    triggerMode: "hover"
    open: root.popupOpen

    // fittedContentHeight() folds in the card's vertical padding and border
    // for you; fittedContentWidth() has no horizontal counterpart and takes a
    // finished card width, so the inset has to be added here or the longest
    // rows (RFC 2822, Unix readable) get clipped at the border.
    readonly property real horizontalInset: padding * 2
      + Border.left(borderSpec) + Border.right(borderSpec)

    contentWidth: popup.fittedContentWidth(content.implicitWidth + popup.horizontalInset)
    contentHeight: popup.fittedContentHeight(content.implicitHeight)

    Column {
      id: content
      anchors.left: parent.left
      anchors.top: parent.top
      spacing: Style.space(2)

      PanelSectionHeader {
        text: "TIMESTAMP"
        foreground: root.popupForeground
        fontFamily: root.popupFontFamily
      }

      Repeater {
        model: root.timestampRows
        delegate: formatRow
      }

      Item { width: 1; height: Style.space(8) }

      PanelSectionHeader {
        text: "DATE FORMATS"
        foreground: root.popupForeground
        fontFamily: root.popupFontFamily
      }

      Repeater {
        model: root.dateRows
        delegate: formatRow
      }
    }
  }

  // One row shape for both sections: a tick gutter, a fixed-width label
  // column, then the value. Fixing the label column is what holds every
  // value at the same x regardless of label length.
  Component {
    id: formatRow

    Row {
      required property var modelData
      readonly property bool active: root.formatClass === modelData.key
      readonly property string value: root.valueFor(modelData.key)

      visible: value !== ""
      spacing: Style.space(8)

      Text {
        width: markMetrics.advanceWidth
        text: parent.active ? "✓" : ""
        color: Color.accent
        font.family: root.popupFontFamily
        font.pixelSize: root.popupFontSize
        verticalAlignment: Text.AlignVCenter
      }

      Text {
        width: labelMetrics.advanceWidth
        text: parent.modelData.label
        color: root.popupDim
        font.family: root.popupFontFamily
        font.pixelSize: root.popupFontSize
        verticalAlignment: Text.AlignVCenter
      }

      Text {
        text: parent.value
        color: parent.active ? Color.accent : root.popupForeground
        font.family: root.popupFontFamily
        font.pixelSize: root.popupFontSize
        font.bold: parent.active
        verticalAlignment: Text.AlignVCenter
      }
    }
  }

  IpcHandler {
    target: "unixtime"

    function copy(): void { root.copyCurrent() }
    function toggle(): void { root.toggleFormat() }
    function cycle(): void { root.cycleFormat(false) }
    function cycleBack(): void { root.cycleFormat(true) }
    function restart(): void { root.broadcast("restartStream") }

    // The panel is hover-driven, but opening it by hand is what makes it
    // testable without warping the pointer, and lets a keybind summon it.
    function showPanel(): void { root.broadcast("openPanel") }
    function hidePanel(): void { root.broadcast("closePanel") }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.local.omarchy-vibez"
  ipcTarget: "io.github.local.omarchy-vibez"

  readonly property bool showTitle: setting("showTitle", true) !== false
  readonly property bool showArtist: setting("showArtist", true) !== false
  readonly property bool hideWhenClosed: setting("hideWhenClosed", false) === true
  readonly property string leftClick: String(setting("leftClick", "Open panel"))
  readonly property bool panelOnLeft: leftClick !== "Play/pause"

  readonly property var players: Mpris.players ? Mpris.players.values : []
  readonly property var player: findVibez()
  readonly property bool live: player !== null && player !== undefined
  readonly property bool playing: live && (
    player.playbackState === MprisPlaybackState.Playing ||
    player.isPlaying === true
  )

  readonly property string trackTitle: live ? String(player.trackTitle || "") : ""
  readonly property string trackArtist: live ? String(player.trackArtist || "") : ""
  readonly property string trackAlbum: live ? String(player.trackAlbum || "") : ""
  readonly property string artUrl: live ? String(player.trackArtUrl || player.artUrl || "") : ""
  readonly property string label: barLabel()
  readonly property real trackLength: live ? Math.max(0, Number(player.length || 0)) : 0
  readonly property real trackPosition: live ? Math.max(0, Number(player.position || 0)) : 0

  readonly property color contentForeground: bar ? bar.barForeground : Color.foreground
  readonly property color dimForeground: Qt.darker(contentForeground, 1.55)
  readonly property color subtleFill: Style.normalFillFor(contentForeground, Color.accent)
  readonly property color subtleBorder: Style.normalBorderFor(contentForeground, Color.accent)
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property bool shown: live || !hideWhenClosed

  visible: shown
  implicitWidth: shown ? button.implicitWidth : 0
  implicitHeight: shown ? button.implicitHeight : 0

  Timer {
    interval: 1000
    running: root.playing
    repeat: true
    onTriggered: if (root.player) root.player.positionChanged()
  }

  Process {
    id: launchVibez
    command: ["sh", "-lc", "uwsm app -- ghostty -e vibez || uwsm app -- alacritty -e vibez || uwsm app -- kitty -e vibez || xdg-terminal-exec vibez || vibez"]
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf001"
    active: root.opened
    useActiveColor: root.playing
    foreground: root.live
      ? (root.playing ? Color.accent : root.contentForeground)
      : root.dimForeground
    tooltipText: root.live
      ? (root.label || root.trackTitle || root.trackArtist || "vibez")
      : "Launch vibez"

    onPressed: function(buttonCode) {
      if (!root.live) {
        launchVibez.running = true
        return
      }

      if ((buttonCode === Qt.LeftButton && !root.panelOnLeft) ||
          buttonCode === Qt.MiddleButton ||
          buttonCode === Qt.RightButton) {
        root.player.togglePlaying()
      } else {
        root.toggle()
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(root.live ? 360 : 236))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent

      onMoveRequested: function(dx, dy) {
        if (dx > 0 && root.player && root.player.canGoNext) root.player.next()
        else if (dx < 0 && root.player && root.player.canGoPrevious) root.player.previous()
      }
      onActivateRequested: if (root.player) root.player.togglePlaying()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        if (text === " " && root.player) root.player.togglePlaying()
        else if (text === "n" && root.player && root.player.canGoNext) root.player.next()
        else if (text === "p" && root.player && root.player.canGoPrevious) root.player.previous()
        else if (text === "o") launchVibez.running = true
      }

      Column {
        id: contentColumn
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(10)

        Row {
          visible: root.live
          width: parent.width
          spacing: Style.space(12)

          Rectangle {
            id: cover
            width: Style.space(92)
            height: width
            radius: Style.cornerRadius
            color: root.subtleFill
            border.width: Math.max(1, Style.space(1))
            border.color: root.subtleBorder
            clip: true

            Text {
              anchors.centerIn: parent
              text: "\uf001"
              color: Color.accent
              opacity: 0.42
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.displayLarge
            }

            Image {
              anchors.fill: parent
              visible: root.artUrl !== "" && status !== Image.Error
              source: root.artUrl
              sourceSize.width: Style.space(220)
              sourceSize.height: Style.space(220)
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              cache: true
            }
          }

          Column {
            width: parent.width - cover.width - parent.spacing
            anchors.verticalCenter: cover.verticalCenter
            spacing: Style.space(4)

            Text {
              width: parent.width
              text: root.trackTitle || "vibez"
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.subtitle
              font.bold: true
              wrapMode: Text.Wrap
              elide: Text.ElideRight
              maximumLineCount: 2
            }

            Text {
              width: parent.width
              text: root.trackArtist || "Apple Music"
              color: root.contentForeground
              opacity: 0.82
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.body
              elide: Text.ElideRight
              maximumLineCount: 1
            }

            Text {
              visible: root.trackAlbum !== ""
              width: parent.width
              text: root.trackAlbum
              color: root.dimForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
              elide: Text.ElideRight
              maximumLineCount: 1
            }
          }
        }

        Row {
          visible: !root.live
          width: parent.width
          height: Style.space(38)
          spacing: Style.space(10)

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "\uf001"
            color: root.dimForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.icon
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "vibez is not running"
            color: root.dimForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.body
          }
        }

        Column {
          visible: root.live
          width: parent.width
          spacing: Style.space(2)

          PanelSlider {
            width: parent.width
            bar: root.bar
            minimum: 0
            maximum: Math.max(1, root.trackLength)
            value: Math.min(root.trackPosition, Math.max(1, root.trackLength))
            step: 5
            trackHeight: Math.max(3, Style.space(3))
            knobSize: Style.space(10)
            onReleased: function(nextPosition) {
              if (root.player && root.trackLength > 0) root.player.position = nextPosition
            }
          }

          RowLayout {
            width: parent.width

            Text {
              text: root.formatTime(root.trackPosition)
              color: root.dimForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
            }

            Item { Layout.fillWidth: true }

            Text {
              text: root.formatTime(root.trackLength)
              color: root.dimForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
            }
          }
        }

        Item {
          width: parent.width
          height: Style.space(34)

          Row {
            anchors.centerIn: parent
            spacing: Style.space(14)

            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: "\uf048"
              tooltipText: "Previous track"
              foreground: root.contentForeground
              hoverColor: Color.accent
              fontFamily: root.contentFontFamily
              fontSize: Style.font.body
              size: Style.space(28)
              bordered: false
              enabled: root.player && root.player.canGoPrevious
              onClicked: root.player.previous()
            }

            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: root.playing ? "\uf04c" : "\uf04b"
              tooltipText: root.playing ? "Pause" : "Play"
              foreground: Color.accent
              hoverColor: Color.accent
              fontFamily: root.contentFontFamily
              fontSize: Style.font.iconLarge
              size: Style.space(34)
              bordered: false
              enabled: root.player && (root.player.canTogglePlaying || root.player.canPlay || root.player.canPause || root.player.canControl)
              onClicked: root.player.togglePlaying()
            }

            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: "\uf051"
              tooltipText: "Next track"
              foreground: root.contentForeground
              hoverColor: Color.accent
              fontFamily: root.contentFontFamily
              fontSize: Style.font.body
              size: Style.space(28)
              bordered: false
              enabled: root.player && root.player.canGoNext
              onClicked: root.player.next()
            }

            PanelActionButton {
              anchors.verticalCenter: parent.verticalCenter
              iconText: "\uf120"
              tooltipText: "Open vibez"
              foreground: root.contentForeground
              hoverColor: Color.accent
              fontFamily: root.contentFontFamily
              fontSize: Style.font.body
              size: Style.space(28)
              bordered: false
              onClicked: launchVibez.running = true
            }
          }
        }
      }
    }
  }

  function findVibez() {
    for (var i = 0; i < players.length; i++) {
      var candidate = players[i]
      var identity = String(candidate.identity || "").toLowerCase()
      var desktopEntry = String(candidate.desktopEntry || "").toLowerCase()
      var busName = String(candidate.busName || candidate.dbusName || "").toLowerCase()

      if (identity === "vibez" ||
          desktopEntry === "io.github.simonepelosi.vibez" ||
          desktopEntry === "vibez" ||
          busName.indexOf("org.mpris.mediaplayer2.vibez") !== -1) {
        return candidate
      }
    }
    return null
  }

  function barLabel() {
    if (!live) return ""
    if (!showTitle && !showArtist) return ""
    if (showTitle && showArtist && trackTitle && trackArtist) return trackTitle + " - " + trackArtist
    if (showTitle && trackTitle) return trackTitle
    if (showArtist && trackArtist) return trackArtist
    return trackTitle || trackArtist
  }

  function formatTime(seconds) {
    if (!seconds || seconds <= 0) return "0:00"
    var totalSeconds = Math.floor(seconds)
    var minutes = Math.floor(totalSeconds / 60)
    var remainingSeconds = totalSeconds % 60
    return minutes + ":" + (remainingSeconds < 10 ? "0" : "") + remainingSeconds
  }
}

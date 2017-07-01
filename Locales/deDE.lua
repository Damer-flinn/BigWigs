local L = BigWigsAPI:NewLocale("BigWigs", "deDE")
if not L then return end

L.getNewRelease = "Dein BigWigs ist veraltet (/bwv), aber du kannst es mit Hilfe des Curse Client einfach aktualisieren. Alternativ kannst du es auch von curse.com oder wowinterface.com herunterladen und manuell aktualisieren."
L.warnTwoReleases = "Dein BigWigs ist 2 Versionen älter als die neueste Version! Deine Version könnte Fehler, fehlende Funktionen oder völlig falsche Timer beinhalten. Es wird dringend empfohlen, BigWigs zu aktualisieren."
L.warnSeveralReleases = "|cffff0000Dein BigWigs ist um %d Versionen veraltet!! Wir empfehlen dir DRINGEND, BigWigs zu aktualisieren, um Synchronisationsprobleme zwischen dir und anderen Spielern zu verhindern!|r"

L.gitHubDesc = "BigWigs ist Open-Source-Software auf GitHub. Wir sind immer auf der Suche nach neuen Menschen, die uns helfen, und jeder ist willkommen, unseren Code zu inspizieren, Beiträge zu leisten und Fehlerberichte einzureichen. BigWigs ist hauptsächlich durch die großartige WoW-Gemeinschaft im Laufe der Zeit zu etwas Großem geworden.\n\n|cFF33FF99Unsere API ist nun dokumentiert und frei lesbar im Wiki auf GitHub.|r"

L.options = "Optionen"
L.raidBosses = "Schlachtzugsbosse"
L.dungeonBosses = "Dungeonbosse"

L.infobox = "Informationsbox"
L.infobox_desc = "Zeigt eine Box mit Informationen zur Bossbegegnung an"
L.INFOBOX = L.infobox
L.INFOBOX_desc = L.infobox_desc

L.disabledAddOn = "Du hast das Addon |cFF436EEE%s|r deaktiviert, Timer werden nicht angezeigt."

L.activeBossModules = "Aktive Bossmodule:"
L.advanced = "Erweiterte Optionen"
L.alphaRelease = "Bei dir läuft ein ALPHA RELEASE von BigWigs %s (%s)."
L.already_registered = "|cffff0000WARNUNG:|r |cff00ff00%s|r (|cffffff00%s|r) existiert bereits als Modul in BigWigs, aber irgend etwas versucht es erneut anzumelden. Dies bedeutet normalerweise, dass du zwei Kopien des Moduls aufgrund eines Fehlers beim Aktualisieren in deinem Addon-Ordner hast. Es wird empfohlen, jegliche BigWigs-Ordner zu löschen und dann von Grund auf neu zu installieren."
L.altpower = "Anzeige alternativer Energien"
L.ALTPOWER = "Anzeige alternativer Energien"
L.altpower_desc = "Zeigt ein Fenster mit alternativen Energien der einzelnen Gruppenmitglieder."
L.ALTPOWER_desc = "Einige Bosse nutzen die alternativen Energien für Mitspieler in der Gruppe. Die Anzeige alternativer Energien bietet einen schnellen Überblick darüber, wer am meisten/wenigsten alternative Energie besitzt. Dies kann bei Taktiken oder Einteilungen helfen."
L.back = "<< Zurück"
L.BAR = "Leisten"
L.BAR_desc = "Leisten werden für Bossfähigkeiten angezeigt, sofern sie sinnvoll sind. Falls diese Fähigkeit eine Leiste besitzt, die du verstecken möchtest, kannst du die Option deaktivieren."
L.berserk = "Berserker"
L.berserk_desc = "Warnt, wenn der Boss zum Berserker wird."
L.best = "Beste:"
L.blizzRestrictionsConfig = "Aufgrund der Beschränkungen von Blizzard muss die Konfiguration zuerst ausserhalb des Kampfes geöffnet werden bevor dies im Kampf möglich ist."
L.blizzRestrictionsZone = "Warte bis zum Ende des Kampfes, um BigWigs vollständig zu Laden. (Blizzards Kampfeinschränkungen)."
L.chatMessages = "Chatfenster-Nachrichten"
L.chatMessagesDesc = "Gibt alle BigWigs-Nachrichten im Standard-Chatfenster aus, zusätzlich zu der Einstellung unter 'Ausgabe'."
L.colors = "Farben"
L.configure = "Einstellungen"
L.coreAddonDisabled = "BigWigs wird nicht richtig funktionieren, da das Addon %s deaktiviert ist. Du kannst es über die Addonkonfiguration im Charakterauswahlmenü aktivieren."
L.COUNTDOWN = "Countdown"
L.COUNTDOWN_desc = "Wenn aktiviert, wird ein hör- und sichtbarer Countdown für die letzten 5 Sekunden hinzugefügt. Stell dir vor es zählt jemand runter \"5... 4... 3... 2... 1...\" mit einer großen Zahl in der Mitte des Bildschirms."
L.dbmFaker = "Täusche vor, dass ich DBM nutze"
L.dbmFakerDesc = "Wenn ein DBM-Nutzer eine Versionskontrolle ausführt erscheinst du in der Liste. Nützlich für Gilden die auf DBM bestehen."
L.dbmUsers = "DBM-Nutzer:"
L.DISPEL = "Nur Dispeller"
L.DISPEL_desc = "Wenn Du Warnungen für diese Fähigkeit sehen willst, obwohl du sie nicht bannen kannst, deaktiviere diese Option."
L.dispeller = "|cFFFF0000Warnungen nur für Banner.|r "
L.EMPHASIZE = "Hervorheben"
L.EMPHASIZE_desc = "Wenn diese Funktion aktiviert wird, werden Nachrichten, die mit dieser Fähigkeit verbunden sind, hervorgehoben. Dadurch werden sie größer und besser sichtbar. Du kannst die Größe und Schriftart von hervorgehobenen Nachrichten in den Haupteinstellungen unter \"Nachrichten\" einstellen."
L.finishedLoading = "Kampf ist vorbei, BigWigs ist nun vollständig geladen."
L.FLASH = "Aufleuchten"
L.FLASH_desc = "Einige Fähigkeiten mögen wichtiger sein als andere. Wenn Du bei auftreten oder kurz vor dieser Fähigkeit den Bildschirm aufleuchten lassen möchtest, aktiviere diese Option."
L.flashScreen = "Bildschirm aufleuchten lassen"
L.flashScreenDesc = "Einige wichtige Fähigkeiten erfordern volle Aufmerksamkeit. Beim Auftreten dieser Fähigkeiten kann BigWigs den Bildschirm aufleuchten lassen."
L.flex = "Flexibel"
L.healer = "|cFFFF0000Warnungen nur für Heiler.|r "
L.HEALER = "Nur Heiler"
L.HEALER_desc = "Einige Fähigkeiten sind lediglich für Heiler wichtig. Wenn Du Warnungen für diese Fähigkeit unabhägig von Deiner Rolle angezeigt bekommen möchtest, deaktiviere diese Option."
L.heroic = "Heroisch"
L.heroic10 = "10 HC"
L.heroic25 = "25 HC"
L.ICON = "Symbole"
L.ICON_desc = "BigWigs kann Spieler, die von Fähigkeiten betroffen sind, durch ein Symbol markieren. Das erleichtert das Bemerken."
L.introduction = "Willkommen bei BigWigs, dort, wo die Bossbegegnungen rumschwirren. Bitte legen Sie Ihren Sicherheitsgurt an, stellen Sie die Rückenlehne gerade und genießen Sie den Flug. Wir werden Ihnen und Ihrer Raidgruppe bei der Begegnung mit Bossen zur Hand gehen und sie Ihnen als 7-Gänge-Menü zubereiten."
L.kills = "Siege:"
L.lfr = "LFR"
L.listAbilities = "Fähigkeiten im Chat auflisten"
L.ME_ONLY = "Nur anzeigen, wenn ich betroffen bin"
L.ME_ONLY_desc = "Wenn diese Option aktiviert ist wird diese Fähigkeit nur angezeigt, wenn du betroffen bist. Zum Beispiel wird 'Bombe: Spieler' nur angezeigt, wenn dies dich betrifft."
L.MESSAGE = "Nachrichten"
L.MESSAGE_desc = "Für die meisten Bossfähigkeiten gibt es eine oder mehrere Nachrichten, die BigWigs anzeigt. Wenn du diese Option deaktivierst, wird keine der zugehörigen Nachrichten angezeigt."
L.minimapIcon = "Minikartensymbol"
L.minimapToggle = "Zeigt oder versteckt das Minikartensymbol."
L.missingAddOn = "Bitte beachte, dass diese Zone das |cFF436EEE%s|r-Plugin für Timer zur Anzeige benötigt."
L.modulesDisabled = "Alle laufenden Module wurden beendet."
L.modulesReset = "Alle laufenden Module wurden zurückgesetzt."
L.mythic = "Mythisch"
L.noBossMod = "Kein Bossmod:"
L.norm10 = "10"
L.norm25 = "25"
L.normal = "Normal"
L.officialRelease = "Bei dir läuft ein offizieller Release von BigWigs %s (%s)."
L.offline = "Offline"
L.oldVersionsInGroup = "Es gibt Leute in deiner Gruppe mit veralteten Versionen oder ohne BigWigs. Mehr Details mit /bwv."
L.outOfDate = "Veraltet:"
L.PROXIMITY = "Näheanzeige"
L.PROXIMITY_desc = "Fähigkeiten von Begegnungen erfordern manchmal, dass alle Mitspieler auseinander stehen. Die Näheanzeige wird speziell für diese Fähigkeit eingestellt, so dass du auf einen Blick siehst, ob du sicher bist oder nicht."
L.PULSE = "Impuls"
L.PULSE_desc = "Zusätzlich zum Aufleuchten des Bildschirms kann für diese bestimmte Fähigkeit kurzzeitig ein Symbol in der Bildschirmmitte angezeigt werden, um deine Aufmerksamkeit zu erlangen."
L.removeAddon = "Bitte entferne '|cFF436EEE%s|r', da es durch '|cFF436EEE%s|r' ersetzt wurde."
L.resetPositions = "Positionen zurücksetzen"
L.SAY = "Sagen"
L.SAY_desc = "Chatblasen sind leicht zu sehen. BigWigs benutzt eine /sagen-Nachricht, um Leute um dich herum auf Effekte auf dir aufmerksam zu machen."
L.selectEncounter = "Wähle Begegnung"
L.slashDescBreak = "|cFFFED000/break:|r Sendet einen Pausentimer an den Schlachtzug."
L.slashDescConfig = "|cFFFED000/bw:|r Öffnet die BigWigs Konfiguration."
L.slashDescLocalBar = "|cFFFED000/localbar:|r Erstellt eine Custombar, welche nur Du sehen kannst."
L.slashDescPull = "|cFFFED000/pull:|r Sendet einen Countdown zum Pull an den Raid."
L.slashDescRaidBar = "|cFFFED000/raidbar:|r Sendet eine Custombar an den Raid."
L.slashDescRange = "|cFFFED000/range:|r Öffnet die Reichweitenanzeige."
L.slashDescTitle = "|cFFFED000Slash-Befehle:|r"
L.slashDescVersion = "|cFFFED000/bwv:|r Führt einen BigWigs Versionscheck durch."
L.sound = "Sound"
L.sourceCheckout = "Bei dir läuft ein Source Code Checkout von BigWigs %s direkt aus dem Repository."
L.stages = "Phasen"
L.stages_desc = "Funktionen für bestimmte Phasen von Bossbegegnungen wie Abstandscheck oder Leisten aktivieren.."
L.statistics = "Statistiken"
L.tank = "|cFFFF0000Warnungen nur für Tanks.|r "
L.TANK = "Nur Tank"
L.TANK_desc = "Einige Fähigkeiten sind lediglich für Tanks wichtig. Wenn Du Warnungen für diese Fähigkeit unabhägig von Deiner Rolle angezeigt bekommen möchtest, deaktiviere diese Option."
L.tankhealer = "|cFFFF0000Warnung nur für Tanks und Heiler.|r "
L.TANK_HEALER = "Nur Tank & Heiler"
L.TANK_HEALER_desc = "Einige Fähigkeiten sind lediglich für Tanks und Heiler wichtig. Wenn Du Warnungen für diese Fähigkeit unabhägig von Deiner Rolle angezeigt bekommen möchtest, deaktiviere diese Option."
L.test = "Testen"
L.testBarsBtn = "Testleiste anzeigen"
L.testBarsBtn_desc = "Zeigt eine Leiste zum Testen der aktuellen Einstellungen an."
L.toggleAnchorsBtn = "Anker ein-/ausblenden"
L.toggleAnchorsBtn_desc = "Blendet die Ankerpunkte ein oder aus."
L.tooltipHint = [=[|cffeda55fKlicken|r, um alle laufenden Module zurückzusetzen.
|cffeda55fAlt+Klick|r, um alle laufenden Module zu beenden.
|cffeda55fRechtsklick|r, um auf die Optionen zuzugreifen.]=]
L.upToDate = "Aktuell:"
L.VOICE = "Stimmen"
L.VOICE_desc = "Wenn ein Stimmplugin installiert ist, aktiviert diese Option die Wiedergabe einer Sounddatei, welche die Warnung laut ausspricht."
L.warmup = "Bosskampf beginnt"
L.warmup_desc = "Verbleibende Zeit bis zum Start der Bossbegegnung."
L.wipes = "Niederlagen:"
L.zoneMessages = "Gebietsmeldungen anzeigen"
L.zoneMessagesDesc = "Wenn Du diese Option deaktivierst, zeigt BigWigs beim Betreten von Gebieten ohne installierte Bossmods keine Meldungen mehr an. Es wird empfohlen, diese Option aktiviert zu lassen, da sie über neu erstellte Timer für neue Gebiete informiert."


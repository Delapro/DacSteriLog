Function New-Fehlerbeschreibung {
    [CmdletBinding()]
    Param(
        [int]$CodeNr,
        [string]$Beschreibung,
        [string]$Fehlerbehebung
    )
    [PSCustomObject]@{CodeNr=$CodeNr;Beschreibung=$Beschreibung;Fehlerbehebung=$Fehlerbehebung}
}

$FehlerBeschreibungen=@()
$FehlerBeschreibungen += New-Fehlerbeschreibung -CodeNr 60 -Beschreibung @"
Die Kammertemperatur und die theoretische Dampftemperatur weichen um mehr als 2K voneinander ab.
"@ -Fehlerbehebung @"
Wenden Sie sich bitte an Ihren autorisierten Händler.
"@

$FehlerBeschreibungen += New-Fehlerbeschreibung -CodeNr 61 -Beschreibung @"
Die Software hat über 3 Minuten lang keine Temperaturänderung im Dampfgenerator registriert.
"@ -Fehlerbehebung @"
Wenden Sie sich bitte an Ihren autorisierten Händler.
"@

<#
62 Die für den Druckaufbau zur
Sterilisation notwendige
Temperatur wurde innerhalb von
7 ½ Minuten nicht erreicht.
Erhöhen Sie die Stufe der „Umgebungstemperatur-Empfindlichkeit“
Einstellungen.
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder
destilliertes Wasser (Wasserleitfähigkeit < 3,0 µS/cm) in den Wassertank.
Wenn sich der DAC UNIVERSAL in einem Raum < 16° C befindet, heizen
Sie den Raum auf Raumtemperatur.
Drücken Sie zum Zurücksetzen die „Clear“-Taste und starten Sie den
DAC UNIVERSAL erneut.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
63 Falsche Einstellung des
Wasserstandschalters
Wenden Sie sich bitte an Ihren autorisierten Händler.
64 Das Sicherheitssystem wurde
aktiviert.
Wenden Sie sich bitte an Ihren autorisierten Händler.
65 Das Sicherheitssystem ist
defekt.
Wenden Sie sich bitte an Ihren autorisierten Händler.
66 Die Temperatur während der
Sterilisation war zu hoch.
Wenden Sie sich bitte an Ihren autorisierten Händler.
67 Die Sterilisationszeit betrug
weniger als 3 Minuren.
Die Instrumente müssen nochmals sterilisiert werden.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
68 Der Druck während des
Drucktests ist zu hoch.
Wenden Sie sich bitte an Ihren autorisierten Händler.
#>

$FehlerBeschreibungen += New-Fehlerbeschreibung -CodeNr 70 -Beschreibung @"
Das Druckniveau in der Kammer sinkt nach der Druckprüfung nicht schnell genug.
"@ -Fehlerbehebung @"
Lassen Sie Wasser aus der Kammer ab.
Reinigen oder wechseln Sie den Abwasserfilter, siehe „Reinigen des Abwasserfilters [ → 199]“ bzw. „Wechseln des Abwasserfilters [ → 211]“.
Stellen Sie sicher, dass der Abwasserschlauch nicht blockiert, defekt oder abgeknickt ist.
(WICHTIG: der Abwasserschlauch muss aus einem hitzefesten Material, wie beispielsweise PTFE, bestehen).
Leeren Sie den Abwasserbehälter, wenn dieser voll ist.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren autorisierten Händler.
"@

<#
71 Der DAC UNIVERSAL ist
blockiert auf Grund von
unzureichender Wasserqualität
im Wassertank.
Entleeren Sie nach Bedarf den Wassertank.
Füllen Sie frisches demineralisiertes oder destilliertes Wasser auf
(Wasserleitfähigkeit < 3,0 µS/cm).
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
72 Der Deckel lässt sich nicht
öffnen.
Entfernen Sie eine mögliche Blockade des Deckels.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
73 Die Sterilisationstemperatur
konnte während des Back-Flush
nicht gehalten werden.
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder
destilliertes Wasser (Wasserleitfähigkeit < 3,0 µS/cm) in den Wassertank.
Drücken Sie zum Zurücksetzen die „Clear“-Taste und starten Sie den
DAC UNIVERSAL erneut.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
74 Beim Aufheizen zur Sterilisation
wurden innerhalb von 2,5
Minuten nicht 120°C erreicht.
Erhöhen Sie die Stufe der „Umgebungstemperatur-Empfindlichkeit“
Einstellungen.
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder
destilliertes Wasser (Wasserleitfähigkeit < 3,0µS/cm) in den Wassertank.
Wenn sich der DAC UNIVERSAL in einem Raum mit < 16°C befindet,
heizen Sie den Raum auf Raumtemperatur.
Drücken Sie zum Zurücksetzen die „Clear“-Taste und starten Sie den
DAC UNIVERSAL erneut.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
75 Beim Aufheizen zur Sterilisation
von 120°C auf 134°C wurden 2,5
Minuten überschritten.
Erhöhen Sie die Stufe der „Umgebungstemperatur-Empfindlichkeit“
Einstellungen.
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder
destilliertes Wasser (Wasserleitfähigkeit < 3,0 µS/cm) in den Wassertank.
Wenn sich der DAC UNIVERSAL in einem Raum mit < 16°C befindet,
heizen Sie den Raum auf Raumtemperatur.
Drücken Sie zum Zurücksetzen die „Clear“-Taste und starten Sie den
DAC UNIVERSAL erneut.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
76 Ventilfehler Wenden Sie sich bitte an Ihren autorisierten Händler.
77 Ventilfehler Wenden Sie sich bitte an Ihren autorisierten Händler.
78 Ventilfehler Wenden Sie sich bitte an Ihren autorisierten Händler.
79 Ventilfehler Wenden Sie sich bitte an Ihren autorisierten Händler.
80 Nach der Wasserreduzierung
wurde die gewünschte
Sterilisationstemperatur nicht
erreicht.
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder
destilliertes Wasser (Wasserleitfähigkeit < 3,0 µS/cm) in den Wassertank.
Wenden Sie sich bitte an Ihren autorisierten Händler.
#>
$FehlerBeschreibungen += New-Fehlerbeschreibung -CodeNr 81 -Beschreibung @"
Niedriger Füllstand im Wassertank oder in der Ölflasche, siehe Display DAC UNIVERSAL
"@ -Fehlerbehebung @"
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder
destilliertes Wasser (Wasserleitfähigkeit < 3,0 µS/cm) in den Wassertank.
Wechseln Sie die NitramOil #2 Flasche, falls diese leer ist, siehe
„Einsetzen/Auswechseln des Pflegekonzentrates [ → 162]“.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
"@
<#
82 Fehler im Dampfgenerator Wenden Sie sich bitte an Ihren autorisierten Händler.
83 Temperatursensor in der
Kammer ist defekt.
Wenden Sie sich bitte an Ihren autorisierten Händler.
84 Die Sterilisationstemperatur
wurde während der Sterilisation
nicht eingehalten.
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder
destilliertes Wasser (Wasserleitfähigkeit < 3,0 µS/cm) in den Wassertank.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
85 Der Drucksensor ist defekt. Wenden Sie sich bitte an Ihren autorisierten Händler.
#>
$FehlerBeschreibungen += New-Fehlerbeschreibung -CodeNr 86 -Beschreibung @"
Der Sicherheitsring wurde beim Schließen des Deckels aktiviert Drücken Sie zum Zurücksetzen die „Clear“-Taste.
"@ -Fehlerbehebung @"
Stellen Sie sicher, dass der Deckel korrekt in der Deckelhalterung platziert ist.
Starten Sie den Zyklus neu.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren autorisierten Händler.
"@

<#
87 Der Sicherheitsring ist defekt. Wenden Sie sich bitte an Ihren autorisierten Händler.
88 Zu geringer Dampfdruck
während der Sterilisation.
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder
destilliertes Wasser (Wasserleitfähigkeit < 3,0 µS/cm) in den Wassertank.
Drücken Sie zum Zurücksetzen die „Clear“-Taste und starten Sie den
DAC UNIVERSAL erneut.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
89 Zu hoher Dampfdruck während
der Sterilisation.
Wenden Sie sich bitte an Ihren autorisierten Händler.
90 Zu geringer Druck während der
Druckprüfung.
Stellen Sie sicher, dass Ihr Kompressor eingeschaltet ist.
Überprüfen Sie die Dichtung am Deckel. Wenn diese undicht zu sein
scheint, wenden Sie sich bitte an Ihren autorisierten Händler.
Prüfen Sie, ob der Druck des Anschlusses „Air“ an der Geräterückseite 5-
8 bar beträgt. Wenn der Druck während der Anwendung drastisch abfällt,
wenden Sie sich an den Kompressor-Anbieter.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
91 Der Druck ist während der
Druckprüfung abgefallen.
Überprüfen Sie die Dichtung am Deckel. Wenn diese undicht zu sein
scheint, wenden Sie sich bitte an Ihren autorisierten Händler.
Entfernen Sie potenzielle Verschmutzungen.
Stellen Sie sicher, dass der Deckel ordnungsgemäß im Deckelhalter
platziert ist.
Prüfen Sie, ob der O-Ring des Filtergehäuses ordnungsgemäß
angebracht ist.
Wechseln Sie den O-Ring aus, wenn er beschädigt ist.
Bringen Sie den Deckel des Filtergehäuses ordnungsgemäß an.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
#>

$FehlerBeschreibungen += New-Fehlerbeschreibung -CodeNr 92 -Beschreibung @"
Die Spannungsversorgung des DAC UNIVERSAL war unterbrochen oder die „Clear“-Taste wurde während des Zyklus betätigt.
"@ -Fehlerbehebung @"
Drücken Sie zum Zurücksetzen die „Clear“-Taste und starten Sie den DAC UNIVERSAL erneut.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren autorisierten Händler.
"@

<#
93 Der Dampfgenerator ist
überhitzt.
Schalten Sie den DAC UNIVERSAL sofort aus.
Wenden Sie sich bitte an Ihren autorisierten Händler.
95 Der DAC UNIVERSAL hat im
Standby-Modus mehr als 7 mal
Wasser „angefordert”.
Wichtig: Dieser fehler kann nur auftreten, wenn der DAC UNIVERSAL an
einem festen Wasseranschluss angeschlossen ist.
Stellen Sie sicher, dass der DAC UNIVERSAL mit Wasser versorgt wird.
Sofern Fehler 95 durch eine Undichtigkeit verursacht wird, befindet sich
eine größere Lache Wasser unter dem DAC UNIVERSAL auf der
Arbeitsplatte.
Prüfen Sie, ob sich unter dem DAC UNIVERSAL Wasser befindet. Ist dies
der Fall, unterbrechen Sie die Wasserzuleitung zum DAC UNIVERSAL
und wenden Sie sich bitte an Ihren autorisierten Händler.
96 Zu geringer Druck während des
Ausblasens der Instrumente.
Wenden Sie sich bitte an Ihren autorisierten Händler.
#>

$FehlerBeschreibungen += New-Fehlerbeschreibung -CodeNr 97 -Beschreibung @"
Kein Wasser während der Außenreinigung.
"@ -Fehlerbehebung @"
Drücken Sie zum Zurücksetzen die „Clear“-Taste und starten Sie den DAC UNIVERSAL erneut.
Wenn der Wasserstand zu niedrig ist, füllen Sie demineralisiertes oder destilliertes Wasser (Wasserleitfähigkeit < 3,0 µS/cm) in den Wassertank.
Drücken Sie die „Rinse/Flush“-Taste, bis Wasser unten in der Kammer erscheint. Ist dies der Fall, leeren Sie die Kammer, siehe „Entleeren des
Wassertanks“. Erscheint kein Wasser in der Kammer, wenden Sie sich bitte an Ihren
autorisierten Händler.
Leeren Sie den Abwasserbehälter, wenn dieser voll ist.
Reinigen oder wechseln Sie den Abwasserfilter.
Stellen Sie sicher, dass der Abwasserschlauch nicht blockiert, defekt oder abgeknickt ist.
WICHTIG! der Abwasserschlauch muss aus einem hitzefesten Material, wie beispielsweise PTFE, bestehen.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren autorisierten Händler.
"@

<#
98 Der Deckel lässt sich nicht
schließen.
Drücken Sie zum Zurücksetzen die „Clear“-Taste und warten Sie, bis sich
der Deckel in der obersten Position befindet.
Stellen Sie sicher, dass der Deckel ordnungsgemäß im Deckelhalter
platziert wurde.
Achten Sie auf Gegenstände, die ein vollkommenes Schließen verhindern
würden, und entfernen Sie diese.
Starten Sie einen neuen Zyklus.
Wenn der Fehler wiederholt auftritt, wenden Sie sich bitte an Ihren
autorisierten Händler.
99 Die Prorgrammeinstellungen
müssen überprüft werden.
Wenden Sie sich bitte an Ihren autorisierten Händler.
#>

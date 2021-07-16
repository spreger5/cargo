#!/usr/bin/perl
#====================================================================================
#  Base64-/binaer kodierte Datei entschluesseln.
#
#  Prinzipiell wird erwartet, dass in den ersten 500 Bytes der Datei der Typ des Inhalts
#  (Zertifikat, CSR, ...) als ASCII-Text spezifiziert ist. In diesem Falle ist
#  die Endung der Datei irrelevant, d.h. deren Typ wird *immer* aus diesen Bytes
#  abgeleitet. Typische Beispiele fuer den Typ des Inhalts:
#
#     -----BEGIN CERTIFICATE-----   oder   -----BEGIN TRUSTED CERTIFICATE-----
#
#        oder
#
#     -----BEGIN NEW CERTIFICATE REQUEST-----
#
#        oder
#
#     -----BEGIN CERTIFICATE REQUEST-----
#
#  Kann der Typ aus dem ASCII-Text der ersten 500 Bytes *nicht* ermittelt werden,
#  dann wird versucht, diesen aus der *Endung* der Datei abzuleiten.
#
#  Die eigentliche Entschluesselung erfolgt unter Windows ueber SprGs CMD-Prozedur
#  'OpenSSL.cmd', sonst ueber 'openssl'.
#  Seit 07.10.2019 wird auch GPG verwendet (fuer PGP-Publickeys). Dies ist drzt. aber
#  nur unter Windows moeglich.
#
#  * Das Debugging ist auch moeglich, wenn in der Umgebung die Variable DEBUG gesetzt ist (egal
#    wie, sie muss nur vorhanden sein).
#
#----------------------------------------------------------------------------------------------
#
#  D-Lib: C:/UtilNT/SFU/apps/util/Spg_MCJobs
#
#  T-Lib Win32: C:/BatNT
#
#  T-Lib  Unix: ~/bin   (Verteilung siehe ./cpy2ZGI17.cmd in D-Lib)
#
#----------------------------------------------------------------------------------------------
#  Parameter: -file ...       [muss] ... Name der zu entschluesselnden Base64-Datei
#
#             -debug|nodebug  [kann] ... Debug-Infos werden (nicht) zusaetzlich ausgegeben.
#----------------------------------------------------------------------------------------------
#  Erstellt von: Gerhard Sprenger
#            am: 05.03.2009
#----------------------------------------------------------------------------------------------
#  Aenderungen: 01. 24.04.2014  Sprenger
#                   Die 1. Zeile darf auch mit '-----BEGIN CERTIFICATE REQUEST-----' beginnen.
#
#               02. 28.02.2015  Sprenger
#                   - Auch binaere Dateien verarbeiten
#
#                   - Ausgabe des SHA-256-Fingerprints bei Zertifikaten
#
#                   - Auch CRLs, P12s, P7Bs verarbeiten
#
#               03. 09.06.2016  Sprenger
#                   - Auch unter Unix lauffaehig machen
#
#                   - D-Lib von C:/BatNT nach C:/UtilNT/SFU/apps/util/Spg_MCJobs aendern
#                     Neue T-Lib fuer Unix
#
#               04. 29.06.2016  Sprenger
#                   - Der Typ des Files wird innerhalb der ersten 500 Bytes, nicht wie
#                     bisher innerhalb der ersten 100 Bytes, ermittelt.
#                     Da PEM-Files auch "Bag Attributes" zu Filebeginn enthalten koennen,
#                     muss der Puffer zur Typ-Erkennung vergroeszert werden.
#
#                   - Auch private und oeffentliche (RSA-) Keys verarbeiten
#
#               05. 13.07.2016  Sprenger
#                   - Im Debug-Modus den Header des zu entschluesselnden Files *nach* einem
#                     NewLine ausgeben. Wenn das File naemlich binaer ist und an "unguenstiger"
#                     Stelle CRs enthaelt, kann man den zuvor ausgegebenen Text nicht mehr
#                     lesen, da er ueberschrieben wird.
#
#               06. 19.02.2017  Sprenger
#                   - Auch Zertifikate mit dem Header '-----BEGIN TRUSTED CERTIFICATE-----'
#                     verarbeiten.
#
#               07. 21.05.2017  Sprenger
#                   - Auch Dateien mit dem Header '-----BEGIN ENCRYPTED PRIVATE KEY-----'
#                     verarbeiten.
#
#                   - Auch Dateien mit dem Header '-----BEGIN PKCS7-----' verarbeiten.
#                     PKCS#7: Cryptographic Message Syntax (CMS) Standard. Allgemeine Syntax fuer Daten,
#                     auf die Kryptographie angewandt wurde, wie z.B. digitale Signaturen und digitale
#                     Umschlaege (Envelopes).
#
#                   - Bevor der konstruierte OpenSSL-Befehl ausgefuehrt wird, wird er noch
#                     ausgegeben. Dies ist speziell in Reverseengineering-Situationen sehr hilfreich.
#
#               08. 29.11.2017  Sprenger
#                   - Die zu dekodierende Datei an OpenSSL gequotet uebergeben, damit deren FQN
#                     aich Blanks enthalten kann.
#
#               09. 07.10.2019  Sprenger
#                   - Auch Dateien mit dem Header '-----BEGIN PGP PUBLIC KEY BLOCK-----'
#                     verarbeiten. Dazu wird aber nicht OpenSSL sondern GPG verwendet.
#
#               10. 12.01.2021  Sprenger
#                   - Der Typ des Files wird innerhalb der ersten 2000 Bytes, nicht wie
#                     bisher innerhalb der ersten 500 Bytes, ermittelt.
#                     Da PEM-Files auch "Bag Attributes" zu Filebeginn enthalten koennen,
#                     muss der Puffer zur Typ-Erkennung vergroeszert werden.
#                     Je nach Version, mit der das File erstellt wurde, sind die "Bag Attributes"
#                     derart grosz, dass die 500 Byte nicht ausreichen.
#
#               11. 16.07.2021  Sprenger
#                   - Auch Dateien mit dem Header '-----BEGIN DSA PRIVATE KEY-----'
#                     verarbeiten. Der Key kann verschluesselt oder unverschluesselt sein.
#
#                   - Auch Dateien mit dem Header '-----BEGIN EC PRIVATE KEY-----'
#                     verarbeiten. Der Key kann verschluesselt oder unverschluesselt sein.
#
#                   - Auch Dateien mit dem Header '-----BEGIN OPENSSH PRIVATE KEY-----'
#                     verarbeiten. Der Key kann verschluesselt oder unverschluesselt sein.
#----------------------------------------------------------------------------------------------

use strict; use warnings;
use Getopt::Long;
use Config;

#--- Unter Win32 muss die ANSI-Unterstuetzung extra installiert und aktiviert werden ---
if ($^O =~ m/MSWin/i) { require Win32::Console::ANSI; }

# --- ANSI-Farben ----
my $ansiEsc = "\e["; # 0x1B [

my $ansiF_HRoSw = $ansiEsc . '1;31;40m';   # Hellrot auf Schwarz
my $ansiF_HGeSw = $ansiEsc . '1;33;40m';   # Hellgelb auf Schwarz
my $ansiF_HGrSw = $ansiEsc . '1;32;40m';   # Hellgruen auf Schwarz
my $ansiF_NGrSw = $ansiEsc . '0;32;40m';   # Normalgruen auf Schwarz
my $ansiF_HWeSw = $ansiEsc . '1;37;40m';   # Hellweisz auf Schwarz
my $ansiF_NWeSw = $ansiEsc . '0;37;40m';   # Normalweisz auf Schwarz
my $ansiF_NullM =            "\e(U";       # Null Mapping, keine Zeichenkonvertierung

my $ansiScr_Cls   = $ansiEsc . '2J';       # Bildschirm loeschen, Cursorposition bleibt erhalten
my $ansiScr_Home  = $ansiEsc . 'H';        # Cursor links oben positionieren

# ---- Globale Einstellungen -------------------------------------------------------
my %sGblOptions = (     # globale Einstellungen. Anpassung ueber Befehlszeile moeglich
   'file'     => '?',   # Name der zu entschluesselnden Base64-Datei
   'debug'    =>  0 ,
                  );
my $bDebug;

my $fBase64Name        = '?';   # Name der zu entschluesselnden Base64-Datei
my $sOpenSslProgName   = '?';   # Name der OpenSSL-CMD-Prozedur von SprG
my $sSshKeygenProgName = '?';   # Name des Programmes 'ssh-keygen'

my $bIsWinPerl64 = 0;           # Ist das Perl unter Windows ein 64-Bit-Programm J/N?

if ($^O =~ m/MSWin/i) {
   if ($Config{archname} =~ m/x86_64/i) {
      $bIsWinPerl64 = 1;
   }
}

   # Drzt. werden in '$sDateiTyp' folgende Typen der Eingabedatei unterschieden:
   #
   #    PGPPUBKEY|PEM        oeffentlicher PGP-Key
   #    PUBKEY|PEM           oeffentlicher Key
   #
   #    PRIVKEY_RSA|PEM      privater Key vom Typ RSA
   #    PRIVKEY_DSA|PEM      privater Key vom Typ DSA
   #    PRIVKEY_ECDSA|PEM    privater Key vom Typ ECDSA
   #    PRIVKEY_OPENSSH|PEM  privater OpenSSH-Key
   #
   #    CSR|PEM              Zertifikats-Signieranforderung, Certificate Sign Request
   #    Zert|PEM             X509-Zertifikat Base64 kodiert
   #    Zert|DER             X509-Zertifikat binaer
   #    CRL|DER              Sperrliste (Certificate Revocation List)
   #    P12|DER              PKCS#12. Personal Information Exchange Syntax Standard
   #    P7B|DER              PKCS#7/CMS. Zertifikate, Envelopes und Signaturen... (ohne private Schluessel?)
   #    P7B|PEM              PKCS#7/CMS. Zertifikate, Envelopes und Signaturen... (ohne private Schluessel?)
   #    ''                   unbekannter Dateityp

my $sDateiTyp = '?';
my $bRaw      =  0;         # generische Auflistung des Inhalts eines SSL-Objektes (asn1parse) J/N

my $bInformParm_Allowed = 1;# Parameter '-inform DER|PEM' erlaubt J/N

my ($sShellCmd, $iShellCmdRC);
my ($sSysout, $sErrorMsg);

   # --- Groeszen fuer Datum und Zeit -------------------------------------------
my $tJetzt;                       # Aktuelle Zeit in Epochensekunden

my ($tJetztTag,   $tJetztMon,   $tJetztJhrJJJJ);
my ($tJetztSek,   $tJetztMin,   $tJetztStd);

   #--- Hilfsvariablen ---

my ($i, $j, $farbe, $x1, $x2, $x3);

   #---

if ($^O =~ m/MSWin/i) {
   $sOpenSslProgName = $ENV{SystemDrive} . '\BatNT\OpenSSL.cmd'; # ruft die hoechste installierte OpenSSL-Version auf
   $sSshKeygenProgName = 'ssh-keygen.exe';
}
else {
   $sOpenSslProgName = 'openssl';
   $sSshKeygenProgName = 'ssh-keygen';
}

#-----------------------------------------------------------------------------------
#---   Operationaler Verarbeitungsteil   -------------------------------------------
#-----------------------------------------------------------------------------------

 ($tJetzt, $tJetztSek, $tJetztMin, $tJetztStd, $tJetztTag, $tJetztMon, $tJetztJhrJJJJ) = GetActTimeItems();

 GetOptions(
            'f|file|if|infile:s'  => \$sGblOptions{'file'},
            'debug|verbose!'      => \$sGblOptions{'debug'},
           );

 $bDebug = $sGblOptions{'debug'};
 if (defined($ENV{'DEBUG'})) {
    $bDebug = 1;
 }

 $fBase64Name = $sGblOptions{'file'};

 PrintGblOptions() if $bDebug;  # Rohwerte (d.h. 1:1) der Optionen ex Befehlszeile ausgeben

 #--- Befehlszeilenoptionen auf Plausibilitaet pruefen --------------------------------------------------------
 #--- Zu entschluesselnde [Base64-]Datei
 if (defined($fBase64Name)  &&  $fBase64Name ne '?'  &&  $fBase64Name ne '' ) {
    unless (-r $fBase64Name) {
       print "Achtung: [Base64-]Datei '$fBase64Name' kann nicht gelesen werden!", chr(7), "\n",
             "         System meldet: $!\n",
             "         Programm wird abgebrochen!!!\n";
       exit 12;
    }

    if ($bDebug) {
       print "[Base64-]Datei: >$fBase64Name<\n";
    }
 }
 else {
    print "Achtung: Kein Name fuer die [Base64-]Datei spezifiziert!", chr(7), "\n",
          "         Parameter '-f ...' verwenden!\n",
          "         Programm wird abgebrochen!!!\n";
    exit 12;
 }

 if ($bDebug) {
    print "Die [Base64-]Datei '$fBase64Name' ist lesbar.\n";
 }

 #--- Type der [Base64-]Datei aus dem Hrader ermitteln ------------------------------------------------------
 #--- Bei binaeren Dateien den Typ aus deren Endung ableiten.

 $sDateiTyp = GetType($fBase64Name);

 if ($sDateiTyp eq '?') {
    # Fehlermeldung wird bereits in Upro ausgegeben
    exit 12;
 }

 if ($bDebug) {
    print "Der Typ der Datei ist '$sDateiTyp'\n";
 }

 # '$sDateiTyp' ist nun eingestellt. Bedeutung siehe zu Beginn bei deren Delaration

 #--- Shellbefehl konstruieren ------------------------------------------------------------------------------
 my $bShellcmdComplete = 0;                     # wenn true, ist der Shellbefehl fertig aufgebaut

 my $sKodierung = (split /\|/, $sDateiTyp)[1];
 $sKodierung = 'DER' if !defined($sKodierung);  # bei unbekannten Datei-Typen ist normalerweise DER die bessere Wahl

 if ($bDebug) {
    print "Deren Kodierung ist '$sKodierung'\n";
 }

 if ($^O =~ m/MSWin/i) {
    $sShellCmd = 'START "OpenSSL" /MIN cmd.exe /c ' . $sOpenSslProgName;
 }
 else {
    $sShellCmd = $sOpenSslProgName;
 }

 if ($sDateiTyp =~ m/^ (Zert|Cert) /ix) {
    $sShellCmd .= ' x509 -fingerprint -sha256 -text -noout';
 }
 elsif ($sDateiTyp =~ m/^ CSR /ix) {
    $sShellCmd .= ' req -text -noout';
 }
 elsif ($sDateiTyp =~ m/^ CRL /ix) {
    $sShellCmd .= ' crl -text -noout';
 }
 elsif ($sDateiTyp =~ m/^ P7B /ix) {
    $sShellCmd .= ' pkcs7 -print_certs -text -noout';
 }
 elsif ($sDateiTyp =~ m/^ P12 /ix) {
    $bInformParm_Allowed = 0;
    $sShellCmd .= ' pkcs12 -info';
 }
 elsif ($sDateiTyp =~ m/^ PRIVKEY_RSA /ix) {
    $sShellCmd .= ' rsa -noout -text';
 }
 elsif ($sDateiTyp =~ m/^ PRIVKEY_DSA /ix) {
    $sShellCmd .= ' dsa -noout -text';
 }
 elsif ($sDateiTyp =~ m/^ PRIVKEY_ECDSA /ix) {
    $sShellCmd .= ' ec -noout -text';
 }
 elsif ($sDateiTyp =~ m/^ PRIVKEY_OPENSSH /ix) {

    if ($^O =~ m/MSWin/i  &&  ! $bIsWinPerl64) {
       print "Fehler: Eine Datei des Typs '$sDateiTyp' kann unter Windows nicht von einem 32-bittigen Perl verarbeitet werden,\n",
             "        da es das Programm '$sSshKeygenProgName' nicht aufrufen kann!\n",
             "        Das Programm wird abgebrochen!\n";
       exit 8;
    }

    $sShellCmd = $sSshKeygenProgName . ' -y -f "' . $fBase64Name . '"';
    $bShellcmdComplete = 1;                     # wenn true, ist der Shellbefehl fertig aufgebaut

 }
 elsif ($sDateiTyp =~ m/^ PUBKEY /ix) {
    $sShellCmd .= ' pkey -pubin -noout -text';
 }
 elsif ($sDateiTyp =~ m/^ PGPPUBKEY /ix) {
    if ($^O =~ m/MSWin/i) {
       $sShellCmd = 'START "GPG" cmd.exe /k "mode 130,200&gpg --list-packets  ' . $fBase64Name . '"';
       $bShellcmdComplete = 1;                     # wenn true, ist der Shellbefehl fertig aufgebaut
    }
    else {
       print "Fehler: Der Typ '$sDateiTyp' der Datei '$fBase64Name' kann (drzt.) nur unter Windows verarbeitet werden,\n",
             "        das Programm wird abgebrochen!\n";
       exit 8;
    }
 }
 elsif ($sDateiTyp eq '') {
    $bRaw = 1;
    print "Achtung: Der Typ der Datei '$fBase64Name' kann nicht festgestellt werden!\n",
          "         Versuche die Datei mittels OpenSSL-Befehl 'asn1parse' (Abstract Syntax Notation) zu verarbeiten!\n";

    $sShellCmd .= ' asn1parse';
 }

 if (! $bShellcmdComplete ) {   # der Shellbefehl ist noch nicht fertig aufgebaut
    if ($sKodierung eq 'DER'  &&  $bInformParm_Allowed) {
       $sShellCmd .= ' -inform DER';
    }

    $sShellCmd .= ' -in "' . $fBase64Name . '"';
 }


 #--- Shellbefehl ist erstellt. Nun wird er ausgefuehrt -----------------------------------------------------

 # Hinweis, welcher Befehl nun ausgefuehrt wird. In Reverseengineering-Situationen sehr hilfreich.
 print "Folgender Befehl wird nun ausgefuehrt:\n>$sShellCmd<\n\n";

 $iShellCmdRC = system($sShellCmd);      # RC des letzten ausgefuehrten Befehls mal 256

 $sErrorMsg = $iShellCmdRC != 0  ?  $!  :  '';

 if ($bDebug) {
    print "Shell-Cmd: >$sShellCmd<\n",
          "Ergebnis des Shell-Befehls, RC: ", $iShellCmdRC, " bzw. ", $iShellCmdRC>>8, ".\n";
 }

 if ($iShellCmdRC != 0) {               # Befehl war fehlerhaft
    print "Achtung: RC ", $iShellCmdRC>>8, " von Programm retourniert!", chr(7), "\n",
          "         Folgender Fehler ist aufgetreten: '$sErrorMsg'\n",
          "         Programm wird abgebrochen!!!\n";
    exit 12;
 }

 #--- Abschluss ---------------------------------------------------------------------------------------------

 exit 0;

#-----------------------------------------------------------------------------------
#---   Subroutinen und Funktionen   ------------------------------------------------
#-----------------------------------------------------------------------------------

 #-----------------------------------------------------------------------------------
 # Name: GetActTimeItems()
 #
 # Zweck: Die aktuellen Zeit-Werte fuer Jahr, Monat, Tag, Stunde, Minute, Sekunde und
 #        Epochensekunden ermitteln und in einzelnen Skalaren als Liste retournieren.
 #        Die Werte fuer Monat sind 1- 12, jene fuer das Jahr in der Form JJJJ.
 #
 # Parameter: keine
 #
 # Interne Routinen: keine
 #
 # Globale Groeszen: keine
 #
 # Ergebnis: Aktuelle Zeitwerte als Liste von Skalaren (Reihenfolge siehe return-Anweisung)
 #-----------------------------------------------------------------------------------

sub GetActTimeItems {

 my ($t, $tSek, $tMin, $tStd, $tTag, $tMon, $tJhr);

  $t = time;               # aktuelle Zeit in Epochensekunden
  ($tSek, $tMin, $tStd, $tTag, $tMon, $tJhr) = (localtime($t))[0..5];

  $tMon += 1;
  $tJhr += 1900;

  return ($t, $tSek, $tMin, $tStd, $tTag, $tMon, $tJhr);

}

 #----------------------------------------------------------------------------------#

 #-----------------------------------------------------------------------------------
 # Name: PrintGblOptions()
 #
 # Zweck: Die aktuellen Werte der Keys des globalen Optionen-Hashes ausgeben.
 #
 #        Diese Routine sollte zu Programmbeginn direkt nach dem Entgegennehmen
 #        der Optionen ex Befehlszeile mittels Funktion GetOptions()
 #        aufgerufen werden.
 #
 # Parameter: keine
 #
 # Interne Routinen: keine
 #
 # Globale Groeszen: Zugriffe R=Lesen, W=Schreiben, U=Aktualisieren
 #
 #                 R - %sGblOptions ... Hash mit den globalen Optionen ex Befehlszeile,
 #                                      die via Funktion GetOptions() abgeholt wurden
 #
 #                 R - @ARGV        ... Befehlszeilenargumente an das Perl-Programm
 #
 # Ergebnis: 1 (immer)
 #-----------------------------------------------------------------------------------

sub PrintGblOptions {

 my $iMaxOptLng = 1;        # max. Laenge der Namen der Optionen-Keys

  printf "\n%s\n\n", 'Optionen, wie sie 1:1 aus der Befehlszeile uebernommen oder defaultet wurden:';

  #--- Zur "optischen" Aufbereitung wird die max. Laenge der Namen der Optionen-Keys ermittelt
  foreach my $k (keys %sGblOptions) {
     my $l = length($k);
     $iMaxOptLng = $l if $l > $iMaxOptLng;
  }

  #--- Key-Namen und deren Werte ausgeben. Der Wert darf auch ein Array[-Pointer] sein
  foreach my $k (sort {lc($a) cmp lc($b)} keys %sGblOptions) {      # Key-Namen lexikographisch sortiert

     if (ref($sGblOptions{$k}) =~ m/ARRAY/i) {
        my $aPtr = $sGblOptions{$k};

        printf "   %-${iMaxOptLng}s ist: %d Elemente\n", $k, scalar(@$aPtr);

        foreach my $i (0 .. @$aPtr-1) {
           printf "      %2d. >%s<\n", $i+1, $aPtr->[$i];
        }
     }
     else {
        printf "   %-${iMaxOptLng}s ist: >%s<\n", $k, $sGblOptions{$k};
     }
  }
  print "\n";

  #--- Ev. Rest in @ARGV[], der nach Aufruf von GetOptions() noch darin enthalten ist

  if (@ARGV) {
     print "   In ARGV[] verbleibender Inhalt, nachdem die Argumente via GetOptions() abgeholt wurden:\n";
     print "      >$_<\n" foreach @ARGV;
     print "\n";
  }

  return 1;

}

 #----------------------------------------------------------------------------------#

 #-----------------------------------------------------------------------------------
 # Name: GetType()
 #
 # Zweck: Dateityp (Zertifikat, CSR, CRL, ...) ermitteln und retournieren.
 #
 #        Bei Base64-kodierten Dateien wird dies aus dem Header abgelesen,
 #        bei binaeren Dateien aus deren Endung.
 #
 #        Bei einem Fehler wird '?' retourniert. Zuvor wird noch eine Fehlermeldung
 #        ausgegeben.
 #
 # Parameter: DSN ... Name der zu analysierenden Datei
 #
 # Interne Routinen: keine
 #
 # Globale Groeszen: keine
 #
 # Ergebnis: 'Zert|<Kodierung>' / 'CSR|<Kodierung>' / ...   siehe Deklaration '$sDateiTyp' zu Programm-Beginn
 #           ''  wenn der Typ nicht ermittelt werden konnte
 #           '?' bei Fehler
 #-----------------------------------------------------------------------------------

sub GetType {

 my $fDsn = shift;      # DSN der zu analysierenden Datei
 my $erg = '?|?';

 my $fh;
 my $fLast4DsnLC;       # die letzten 4 Zeichen des DSNs (ueblicherweise die Datei-Endung), Kleinschreibung
 my $fLast8DsnLC;       # die letzten 8 Zeichen des DSNs, Kleinschreibung
 my $sPuffer;

  if (!open($fh, '<', $fDsn)) {
     print "Abbruch! Kann [Base64]-Datei namens '$fDsn' nicht zum Lesen oeffnen!\n", chr(7),
           "         Das System meldet: $!.\n";
     return $erg;
  }

  $fLast4DsnLC = lc(substr($fDsn, -4));
  $fLast8DsnLC = lc(substr($fDsn, -8));
  if ($bDebug) {
     print "Die Endung - letzte 4 Zeichen - der Datei (in Kleinschreibung) lautet '$fLast4DsnLC'.\n",
           "Die Endung - letzte 8 Zeichen - der Datei (in Kleinschreibung) lautet '$fLast8DsnLC'.\n";
  }

  # Der Puffer sollte mind. so grosz sein, dass alle der folgenden Abfragen "reinpassen". Da PEM-Files auch
  # "Bag Attributes" zu Beginn enthalten koennen, sollte der Puffer sogar noch groeszer sein.

  binmode($fh);
  read($fh, $sPuffer, 2000);
  close($fh);

  #--- Header analysieren ------------------------------------------------------------------------------------

  $erg = '';    # Typ der Datei ist (vorerst) unbekannt

  if ($bDebug) {
     print "\nFile beginnt mit folgendem Inhalt:\n>$sPuffer<\n\n";
  }

  #--- versuche den Typ aus dem Header abzuleiten

  # Typisches "Bag Attribute" zu Begin eines PEM-Files:
  #
  #    Bag Attributes
  #        localKeyID: 31 34 35 38 38 32 34 39 36 34 33 36 32
  #        friendlyName: *.arz.at
  #    subject=/C=AT/ST=Tirol/L=Innsbruck/O=ARZ Allgemeines Rechenzentrum GmbH/OU=IT/CN=*.arz.at
  #    issuer=/C=US/O=GeoTrust Inc./CN=GeoTrust SHA256 SSL CA
  #    -----BEGIN CERTIFICATE-----
  #    MIIG6zCCBdOgAwIBAgIQdGKhc+bdewG84DO0S1ZBITANBgkqhkiG9w0BAQsFADBG
  #

  # Da der untersuchte Puffer mehrzeilig ist, wird beim RegEx-Match der Modifizierer /s verwendet
  # ('.' inkludiert eine Zeilenschaltung [\n]).

  if    ($sPuffer =~ m/^ .*? -----BEGIN \s+ (TRUSTED \s+)? CERTIFICATE----- /six) {
     $erg = 'Zert|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ (NEW \s+)? CERTIFICATE \s+ REQUEST----- /six) {
     $erg = 'CSR|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ DSA \s+ PRIVATE \s+ KEY----- /six) {
     $erg = 'PRIVKEY_DSA|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ EC \s+ PRIVATE \s+ KEY----- /six) {
     $erg = 'PRIVKEY_ECDSA|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ OPENSSH \s+ PRIVATE \s+ KEY----- /six) {
     $erg = 'PRIVKEY_OPENSSH|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ (RSA \s+)? PRIVATE \s+ KEY----- /six) {
     $erg = 'PRIVKEY_RSA|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ (ENCRYPTED \s+)? PRIVATE \s+ KEY----- /six) {
     $erg = 'PRIVKEYRSA|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ PUBLIC \s+ KEY----- /six) {
     $erg = 'PUBKEY|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ PGP \s+ PUBLIC \s+ KEY \s+ BLOCK----- /six) {
     $erg = 'PGPPUBKEY|PEM';
  }
  elsif ($sPuffer =~ m/^ .*? -----BEGIN \s+ PKCS7----- /six) {
     $erg = 'P7B|PEM';
  }

  #--- versuche den Typ (binaerer Dateien) aus der Datei-Endung abzuleiten

  elsif ($fLast4DsnLC eq '.crt'      ||  $fLast4DsnLC eq '.cer'      ||
         $fLast8DsnLC eq '.crt.der'  ||  $fLast8DsnLC eq '.cer.der') {
     $erg = 'Zert|DER';
  }
  elsif ($fLast8DsnLC eq '.crt.pem'  ||  $fLast8DsnLC eq '.cer.pem') {
     $erg = 'Zert|PEM';
  }
  elsif ($fLast4DsnLC eq '.crl' ) {
     $erg = 'CRL|DER';
  }
  elsif ($fLast4DsnLC eq '.p12'  || $fLast4DsnLC eq '.pfx' ) {
     $erg = 'P12|DER';
  }
  elsif ($fLast4DsnLC eq '.p7b' ) {
     $erg = 'P7B|DER';
  }

  return $erg;

}


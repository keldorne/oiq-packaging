; Script Inno Setup pour OIQ (Objective Intelligibility & Quality)
; Code de Xavier Delerce (leblogaudiologie.com) jamais modifie - packaging uniquement.
; Genere l'archive stage/ produite par ci/build-windows.ps1 en installeur .exe autonome.

#define MyAppName "OIQ - Objective Intelligibility & Quality"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Xavier Delerce (leblogaudiologie.com)"
#define StageDir GetEnv("OIQ_STAGE_DIR")

[Setup]
AppId={{7C1B2E3A-9F4D-4B6E-8C2A-3D5E6F7A8B9C}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\OIQ
DefaultGroupName=OIQ
DisableProgramGroupPage=yes
OutputDir=..\..\
OutputBaseFilename=OIQ-Windows-x64-setup
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
; Pas de signature de code (cf. instructions projet) : SmartScreen affichera un avertissement,
; documente pour l'utilisateur final.
WizardStyle=modern

[Files]
Source: "{#StageDir}\env\*"; DestDir: "{app}\env"; Flags: recursesubdirs ignoreversion
Source: "{#StageDir}\app\*"; DestDir: "{app}\app"; Flags: recursesubdirs ignoreversion
Source: "{#StageDir}\oiq.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\OIQ"; Filename: "{app}\oiq.bat"; WorkingDir: "{app}"
Name: "{autodesktop}\OIQ"; Filename: "{app}\oiq.bat"; WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Creer un raccourci sur le Bureau"; GroupDescription: "Raccourcis :"

[Run]
; Finalise l'environnement conda-pack relocalise (equivalent de conda-unpack sous Linux).
Filename: "{app}\env\Scripts\conda-unpack.exe"; \
  WorkingDir: "{app}"; StatusMsg: "Finalisation de l'environnement..."; Flags: runhidden

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

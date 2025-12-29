[Setup]
AppName=MyFlutterApp
AppVersion=1.0.0
DefaultDirName={pf}\MyFlutterApp
DefaultGroupName=MyFlutterApp
OutputDir=installer
OutputBaseFilename=MyFlutterAppSetup
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\MyFlutterApp"; Filename: "{app}\MyFlutterApp.exe"
Name: "{commondesktop}\MyFlutterApp"; Filename: "{app}\MyFlutterApp.exe"
;
; Script generated by the ASCOM Driver Installer Script Generator 6.0.0.0
; Generated by Jolo on 2013-02-26 (UTC)
;
[Setup]
AppName=ASCOM Jolo focuser Focuser Driver
AppVerName=ASCOM Jolo focuser Focuser Driver 2.2
AppVersion=2.2
AppPublisher=Jolo <drjolo@gmail.com>
AppPublisherURL=mailto:drjolo@gmail.com
AppSupportURL=http://tech.groups.yahoo.com/group/ASCOM-Talk/
AppUpdatesURL=http://ascom-standards.org/
VersionInfoVersion=1.5
MinVersion=0,5.0.2195sp4
DefaultDirName="{cf}\ASCOM\Focuser"
DisableDirPage=yes
DisableProgramGroupPage=yes
OutputDir="."
OutputBaseFilename="Jolo focuser Setup"
Compression=lzma
SolidCompression=yes
; Put there by Platform if Driver Installer Support selected
WizardImageFile="C:\Program Files (x86)\ASCOM\Platform 6 Developer Components\Installer Generator\Resources\WizardImage.bmp"
LicenseFile="C:\Program Files (x86)\ASCOM\Platform 6 Developer Components\Installer Generator\Resources\CreativeCommons.txt"
; {cf}\ASCOM\Uninstall\Focuser folder created by Platform, always
UninstallFilesDir="{cf}\ASCOM\Uninstall\Focuser\Jolo focuser"

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Dirs]
Name: "{cf}\ASCOM\Uninstall\Focuser\Jolo focuser"
; TODO: Add subfolders below {app} as needed (e.g. Name: "{app}\MyFolder")

[Files]
Source: "D:\BEKAP\Projects\ascom-jolo-focuser\VisualBasic\JoloFocuser\JoloFocuser\bin\Release\JoloFocuser.dll"; DestDir: "{app}"
; Require a read-me HTML to appear after installation, maybe driver's Help doc
Source: "D:\BEKAP\Projects\ascom-jolo-focuser\VisualBasic\JoloFocuser\JoloFocuser\readme.txt"; DestDir: "{app}"; Flags: isreadme
; TODO: Add other files needed by your driver here (add subfolders above)


; Only if driver is .NET
[Run]
; Only for .NET assembly/in-proc drivers
Filename: "{dotnet2032}\regasm.exe"; Parameters: "/codebase ""{app}\JoloFocuser.dll"""; Flags: runhidden 32bit
Filename: "{dotnet2064}\regasm.exe"; Parameters: "/codebase ""{app}\JoloFocuser.dll"""; Flags: runhidden 64bit; Check: IsWin64




; Only if driver is .NET
[UninstallRun]
; Only for .NET assembly/in-proc drivers
Filename: "{dotnet2032}\regasm.exe"; Parameters: "-u ""{app}\JoloFocuser.dll"""; Flags: runhidden 32bit
Filename: "{dotnet2064}\regasm.exe"; Parameters: "-u ""{app}\JoloFocuser.dll"""; Flags: runhidden 64bit; Check: IsWin64




[CODE]
//
// Before the installer UI appears, verify that the (prerequisite)
// ASCOM Platform 6.0 or greater is installed, including both Helper
// components. Utility is required for all types (COM and .NET)!
//
function InitializeSetup(): Boolean;
var
   U : Variant;
   H : Variant;
begin
   Result := FALSE;  // Assume failure
   // check that the DriverHelper and Utilities objects exist, report errors if they don't
   try
      H := CreateOLEObject('DriverHelper.Util');
   except
      MsgBox('The ASCOM DriverHelper object has failed to load, this indicates a serious problem with the ASCOM installation', mbInformation, MB_OK);
   end;
   try
      U := CreateOLEObject('ASCOM.Utilities.Util');
   except
      MsgBox('The ASCOM Utilities object has failed to load, this indicates that the ASCOM Platform has not been installed correctly', mbInformation, MB_OK);
   end;
   try
      if (U.IsMinimumRequiredVersion(6,0)) then	// this will work in all locales
         Result := TRUE;
   except
   end;
   if(not Result) then
      MsgBox('The ASCOM Platform 6.0 or greater is required for this driver.', mbInformation, MB_OK);
end;


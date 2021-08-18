{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Application;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Variants, Vcl.Forms,
  {$IFDEF REG_STORAGE}System.Win.Registry{$ELSE}System.IniFiles{$ENDIF},
  App.Options, App.Constants;

type
  TCLApplicationClass = class of TCLApplication;

  TCLApplication = class(TComponent)
  private
    class var
      FPath: string;
  protected
    FOptions: TCLOptions;
    FSaveOptions: Boolean;
    FVersion: string;

    function OptionsClass: TCLOptionsClass; virtual; abstract;
    function GetApplicationName: string; virtual;
    function GetVersion: string; virtual;
    function GetConfigFileName: string; virtual;
    function GetRegistryRootKey: string; virtual;
    procedure InternalLoadSettings(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF}); virtual;
    procedure InternalSaveSettings(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF}); virtual;

    property ConfigFileName: string read GetConfigFileName;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure LoadSettings;
    procedure SaveSettings;

    class property Path: string read FPath;
    property ApplicationName: string read GetApplicationName;
    property Version: string read GetVersion;
    property RegistryRootKey: string read GetRegistryRootKey;
    property SaveOptions: Boolean read FSaveOptions write FSaveOptions;
  end;

implementation

{ TCLApplication }

constructor TCLApplication.Create(Owner: TComponent);
begin
  inherited;

  FVersion := '';
  AppName := ApplicationName;
  FOptions := OptionsClass.Create(Self);
  FSaveOptions := True;
  LoadSettings;
end;

destructor TCLApplication.Destroy;
begin
  if SaveOptions then
    SaveSettings;

  inherited;
end;

procedure TCLApplication.LoadSettings;
var
{$IFDEF REG_STORAGE}
  Reg: TRegistry;
{$ELSE}
  IniFile: TIniFile;
  FileName: string;
{$ENDIF}
begin
{$IFDEF REG_STORAGE}
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    InternalLoadSettings(Reg);
  finally
    Reg.Free;
  end;
{$ELSE}
  FileName := AppPath + '\' + ConfigFileName;

  if not FileExists(FileName) then
    raise Exception.Create('"' + FileName + '" не найден');

  IniFile := TIniFile.Create(FileName);
  try
    InternalLoadSettings(IniFile);
  finally
    IniFile.Free;
  end;
{$ENDIF}
end;

procedure TCLApplication.SaveSettings;
var
{$IFDEF REG_STORAGE}
  Reg: TRegistry;
{$ELSE}
  IniFile: TIniFile;
  FileName: string;
{$ENDIF}
begin
{$IFDEF REG_STORAGE}
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;

    InternalSaveSettings(Reg);
  finally
    Reg.Free;
  end;
{$ELSE}
  FileName := AppPath + '\' + ConfigFileName;

  if not FileExists(FileName) then
    raise Exception.Create('"' + FileName + '" не найден');

  IniFile := TIniFile.Create(FileName);
  try
    InternalSaveSettings(IniFile);
  finally
    IniFile.Free;
  end;
{$ENDIF}
end;

function TCLApplication.GetApplicationName: string;
begin
  Result := 'ApplicationName';
end;

function TCLApplication.GetVersion: string;
type
  TFileVersion = packed record
    Minor: Word;
    Major: Word;
    Build: Word;
    Release: Word;
  end;

var
  Stream: TResourceStream;
  Ver: TFileVersion;
begin
  if FVersion <> '' then
    Exit(FVersion);

  FVersion := '1.0.0.0';
  try
    Stream := TResourceStream.Create(HInstance, '#1', RT_VERSION);
    if Stream.Size = 0 then
      Exit(FVersion);

    Stream.Position := 48; // skip data
    Stream.Read(Ver, SizeOf(TFileVersion));
    FVersion := Format('%d.%d.%d.%d', [Ver.Major, Ver.Minor, Ver.Release, Ver.Build]);
  finally
    Stream.Free;
  end;

  Result := FVersion;
end;

function TCLApplication.GetConfigFileName: string;
begin
  Result := 'Config.ini';  //  Result := 'Extdll.ini';
end;

function TCLApplication.GetRegistryRootKey(): string;
begin

end;

procedure TCLApplication.InternalLoadSettings(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF});
begin
  FOptions.Load(Context);
end;

procedure TCLApplication.InternalSaveSettings(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF});
begin
  FOptions.Save(Context);
end;

initialization
  TCLApplication.FPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));

end.
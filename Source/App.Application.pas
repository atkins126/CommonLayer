{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Application;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Vcl.Forms, App.Options, IniFiles;

type
  TCLApplication = class(TComponent)
  private
    FAppPath: String;
    FOptions: TCLOptions;
  protected
    function OptionsClass(): TCLOptionsClass; virtual; abstract;
    function GetApplicationName(): string; virtual;
    function GetConfigFileName(): string; virtual;
    function GetRegistryRootKey(): string; virtual;

    property ConfigFileName: string read GetConfigFileName;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure ReadConfigFromIniFile(); virtual;

    property ApplicationName: string read GetApplicationName;
    property AppPath: string read FAppPath;
    property Options: TCLOptions read FOptions;
    property RegistryRootKey: string read GetRegistryRootKey;
  end;

implementation

{ TCLApplication }

constructor TCLApplication.Create(Owner: TComponent);
begin
  inherited;

  FAppPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  Delete(FAppPath, Length(FAppPath), 1);

  FOptions := OptionsClass.Create(Self);
end;

destructor TCLApplication.Destroy;
begin

  inherited;
end;

function TCLApplication.GetApplicationName(): string;
begin
  Result := 'ApplicationName';
end;

function TCLApplication.GetConfigFileName(): string;
begin
  Result := 'Config.ini';
end;

function TCLApplication.GetRegistryRootKey(): string;
begin

end;

procedure TCLApplication.ReadConfigFromIniFile;
var
  IniFile: TIniFile;
begin
  if not FileExists(AppPath + '\' + ConfigFileName)  then
    raise Exception.Create('"' + AppPath + '\' + ConfigFileName + '" не найден');

  IniFile := TIniFile.Create(AppPath + '\' + ConfigFileName);
  try
    FOptions.LoadFromIniFile(IniFile);
  finally
    IniFile.Free;
  end;
end;

end.

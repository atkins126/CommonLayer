{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Options;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Winapi.Windows,
  App.Options, App.Params,
  {$IFDEF REG_STORAGE}System.Win.Registry{$ELSE}System.IniFiles{$ENDIF};

type
  TCLDBOptions = class(TCLOptions)
  private
    function GetPassword: string;
    function GetPort: Integer;
    function GetServer: string;
    function GetUserName: string;
    procedure SetPassword(const Value: string);
    procedure SetPort(const Value: Integer);
    procedure SetServer(const Value: string);
    procedure SetUserName(const Value: string);
    function GetDatabase: string;
    procedure SetDatabase(const Value: string);
  protected
  {$IFDEF REG_STORAGE}
    FServer: TRegStringParam;
    FPort: TRegIntegerParam;
    FDatabase: TRegStringParam;
    FUserName: TRegStringParam;
    FPassword: TRegStringParam;
  {$ELSE}
    FServer: TIniStringParam;
    FPort: TIniIntegerParam;
    FDatabase: TIniStringParam;
    FUserName: TIniStringParam;
    FPassword: TIniStringParam;
  {$ENDIF}

    function GetDatabaseGroupName: string; virtual;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure Load(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF}); override;
    procedure Save(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF}); override;
    procedure LoadSettingsFromDB; virtual;

    property Server: string read GetServer write SetServer;
    property Port: Integer read GetPort write SetPort;
    property Database: string read GetDatabase write SetDatabase;
    property UserName: string read GetUserName write SetUserName;
    property Password: string read GetPassword write SetPassword;
  end;

implementation

const
  ServerParamName = 'Server';
  PortParamName = 'Port';
  DataBaseParamName = 'Database';
  UserNameParamName = 'Login';
  PasswordParamName = 'Password';

{ TCLDBOptions }

constructor TCLDBOptions.Create(Owner: TComponent);
begin
  inherited;

{$IFDEF REG_STORAGE}
  FServer := TRegStringParam.Create(ServerParamName, GetDatabaseGroupName);
  FPort := TRegIntegerParam.Create(PortParamName, GetDatabaseGroupName);
  FDatabase := TRegStringParam.Create(DataBaseParamName, GetDatabaseGroupName);
  FUserName := TRegStringParam.Create(UserNameParamName, GetDatabaseGroupName);
  FPassword := TRegStringParam.Create(PasswordParamName, GetDatabaseGroupName);
{$ELSE}
  FServer := TIniStringParam.Create(ServerParamName, GetDatabaseGroupName);
  FPort := TIniIntegerParam.Create(PortParamName, GetDatabaseGroupName);
  FDatabase := TIniStringParam.Create(DataBaseParamName, GetDatabaseGroupName);
  FUserName := TIniStringParam.Create(UserNameParamName, GetDatabaseGroupName);
  FPassword := TIniStringParam.Create(PasswordParamName, GetDatabaseGroupName);
{$ENDIF}
end;

destructor TCLDBOptions.Destroy;
begin
  FServer.Free;
  FPort.Free;
  FDatabase.Free;
  FUserName.Free;
  FPassword.Free;

  inherited;
end;

function TCLDBOptions.GetServer: string;
begin
  Result := FServer.Value;
end;

procedure TCLDBOptions.SetServer(const Value: string);
begin
  FServer.Value := Value;
end;

function TCLDBOptions.GetPort: Integer;
begin
  Result := FPort.Value;
end;

procedure TCLDBOptions.SetPort(const Value: Integer);
begin
  FPort.Value := Value;
end;

function TCLDBOptions.GetUserName: string;
begin
  Result := FUserName.Value;
end;

procedure TCLDBOptions.SetUserName(const Value: string);
begin
  FUserName.Value := Value;
end;

function TCLDBOptions.GetPassword: string;
begin
  Result := FPassword.Value;
end;

procedure TCLDBOptions.SetPassword(const Value: string);
begin
  FPassword.Value := Value;
end;

function TCLDBOptions.GetDatabase: string;
begin
  Result := FDatabase.Value;
end;

procedure TCLDBOptions.SetDatabase(const Value: string);
begin
  FDatabase.Value := Value;
end;

function TCLDBOptions.GetDatabaseGroupName: string;
begin
  Result := 'Connection';
end;

procedure TCLDBOptions.Load(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF});
begin
{$IFNDEF CARDS}
  FServer.Load(Context);
  FPort.Load(Context);
  FDatabase.Load(Context);
  FUserName.Load(Context);
{$IFDEF EXTDLL}
  FPassword.Load(Context);
{$ENDIF}
{$ENDIF}
end;

procedure TCLDBOptions.Save(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF});
begin
{$IFNDEF CARDS}
  FServer.Save(Context);
  FPort.Save(Context);
  FDatabase.Save(Context);
  FUserName.Save(Context);
{$IFDEF EXTDLL}
  FPassword.Save(Context);
{$ENDIF}
{$ENDIF}
end;

procedure TCLDBOptions.LoadSettingsFromDB;
begin

end;

end.

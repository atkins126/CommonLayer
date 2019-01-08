{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DBOptions;

interface

uses
  System.Classes, System.SysUtils, System.Variants, IniFiles, App.Options,
  App.Params;

type
  TCLDBOptions = class(TCLOptions)
  private
    FServer: TStringParam;
    FPort: TIntegerParam;
    FDatabase: TStringParam;
    FUserName: TStringParam;
    FPassword: TStringParam;

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
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure LoadFromIniFile(const IniFile: TIniFile); override;
    procedure SaveToIniFile(const IniFile: TIniFile); override;

    procedure LoadSettingsFromDB(); virtual;

    property Server: string read GetServer write SetServer;
    property Port: Integer read GetPort write SetPort;
    property Database: string read GetDatabase write SetDatabase;
    property UserName: string read GetUserName write SetUserName;
    property Password: string read GetPassword write SetPassword;
  end;

implementation

const
  DataBaseGroupName = 'DataBase';
  ServerParamName = 'Server';
  PortParamName = 'Port';
  DataBaseParamName = 'DataBase';
  UserNameParamName = 'Login';
  PasswordParamName = 'Password';

{ TCLDBOptions }

constructor TCLDBOptions.Create(Owner: TComponent);
begin
  inherited;

  FServer := TStringParam.Create(ServerParamName, DataBaseGroupName);
  FPort := TIntegerParam.Create(PortParamName, DataBaseGroupName);
  FDatabase := TStringParam.Create(DataBaseParamName, DataBaseGroupName);
  FUserName := TStringParam.Create(UserNameParamName, DataBaseGroupName);
  FPassword := TStringParam.Create(PasswordParamName, DataBaseGroupName);
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

procedure TCLDBOptions.LoadFromIniFile(const IniFile: TIniFile);
begin
  inherited;

  FServer.Load(IniFile);
  FPort.Load(IniFile);
  FDatabase.Load(IniFile);
  FUserName.Load(IniFile);
  FPassword.Load(IniFile);
end;

procedure TCLDBOptions.SaveToIniFile(const IniFile: TIniFile);
begin
  inherited;

  FServer.Save(IniFile);
  FPort.Save(IniFile);
  FDatabase.Save(IniFile);
  FUserName.Save(IniFile);
  FPassword.Save(IniFile);
end;

procedure TCLDBOptions.LoadSettingsFromDB();
begin

end;

end.

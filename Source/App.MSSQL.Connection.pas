{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.MSSQL.Connection;

interface

uses
  System.Classes, System.SysUtils, System.Variants, App.DB.Connection,
  {$IFDEF UNIDAC}SQLServerUniProvider,{$ENDIF}
  {$IFDEF FIREDAC}FireDAC.Phys.MSSQL, FireDAC.Phys.ODBCBase,{$ENDIF}
  {$I DB_Links.inc};

type
{$IFDEF UNIDAC}
  TMSProvider = (prAuto, prSQL, prNativeClient, prMSOLEDB, prDirect);
{$ENDIF}

  TCLMSConnection = class(TCLDBConnection)
  private
  {$IFDEF UNIDAC}
    function StrToProvider(const Value: string): TMSProvider;
    function ProviderToStr(const Value: TMSProvider): string;
    function GetProvider: TMSProvider;
    procedure SetProvider(const Value: TMSProvider);
  {$ENDIF}
  {$IFDEF FIREDAC}
    FMSSQLDriverLink: TFDPhysMSSQLDriverLink;
  {$ENDIF}
  protected
    procedure DoConnect(const Connection: TDBConnection); override;

    function GetDefaultPort: Integer; override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

  {$IFDEF UNIDAC}
    property Provider: TMSProvider read GetProvider write SetProvider;
  {$ENDIF}
  end;

implementation

uses
  App.Constants;

{ TCLMSConnection }

constructor TCLMSConnection.Create(Owner: TComponent);
begin
  inherited;

{$IFDEF FIREDAC}
  FMSSQLDriverLink := TFDPhysMSSQLDriverLink.Create(Self);
{$ENDIF}
end;

destructor TCLMSConnection.Destroy;
begin
{$IFDEF FIREDAC}
  FMSSQLDriverLink.Free;
{$ENDIF}

  inherited;
end;

{$IFDEF UNIDAC}
function TCLMSConnection.StrToProvider(const Value: string): TMSProvider;
begin
  if SameText(Value, 'prSQL') then
    Result := prSQL
  else
  if SameText(Value, 'prNativeClient') then
    Result := prNativeClient
  else
  if SameText(Value, 'prMSOLEDB') then
    Result := prMSOLEDB
  else
  if SameText(Value, 'prDirect') then
    Result := prDirect
  else
    Result := prAuto;
end;

function TCLMSConnection.ProviderToStr(const Value: TMSProvider): string;
begin
  case Value of
    prSQL:
      Result := 'prSQL';
    prNativeClient:
      Result := 'prNativeClient';
    prMSOLEDB:
      Result := 'prMSOLEDB';
    prDirect:
      Result := 'prDirect';
    else
      Result := 'prAuto';
  end;
end;

function TCLMSConnection.GetProvider: TMSProvider;
var
  pr: string;
begin
  pr := Connection.SpecificOptions.Values['SQL Server.Provider'];
  Result := StrToProvider(pr);
end;

procedure TCLMSConnection.SetProvider(const Value: TMSProvider);
var
  pr: string;
begin
  pr := ProviderToStr(Value);
  Connection.SpecificOptions.Values['SQL Server.Provider'] := pr;
end;
{$ENDIF}

procedure TCLMSConnection.DoConnect(const Connection: TDBConnection);
var
  Server: string;
  UserName: string;
  Password: string;
  Database: string;
  Port: Integer;
begin
  FConnectionStatus := cnNone;
  Connection.Close;

  Server := Self.Server;
  UserName := Self.UserName;
  Password := Self.Password;
  Database := Self.Database;
  Port := Self.Port;

{$IFDEF FIREDAC}
  Connection.Params.Clear;
  Connection.DriverName := 'MSSQL';

  if (Port > 0) and (Port <> DefaultPort) then
    Connection.Params.Add('Server=' + Server + ',' + IntToStr(Port))
  else
    Connection.Params.Add('Server=' + Server);

  Connection.Params.Add('Database=' + Database);
  Connection.Params.Values['User_Name'] := UserName;
  Connection.Params.Values['Password'] := Password;
  Connection.Params.Values['ApplicationName'] := AppName;
  Connection.LoginPrompt := False;
{$ENDIF}

{$IFDEF UNIDAC}
  Connection.ProviderName := 'SQL Server';
//  Connection.SpecificOptions.Values['Provider'] := 'prDirect';
{$ENDIF}

  Connection.Connected := True;
end;

function TCLMSConnection.GetDefaultPort: Integer;
begin
  Result := 1433;
end;

end.

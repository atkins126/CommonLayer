{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
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
  TCLMSConnection = class(TCLDBConnection)
  private
  {$IFDEF FIREDAC}
    FMSSQLDriverLink: TFDPhysMSSQLDriverLink;
  {$ENDIF}
  protected
    procedure DoConnect(const Connection: TDBConnection); override;

    function GetDefaultPort: Integer; override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;
  end;

implementation

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
  FMSSQLDriverLink := TFDPhysMSSQLDriverLink.Create(Self);
{$ENDIF}

  inherited;
end;

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
  Connection.LoginPrompt := False;
{$ENDIF}

{$IFDEF UNIDAC}
  Connection.ProviderName := 'SQL Server';
  Connection.SpecificOptions.Values['Provider'] := 'prNativeClient';  //prDirect
{$ENDIF}

  Connection.Connected := True;
end;

function TCLMSConnection.GetDefaultPort: Integer;
begin
  Result := 1433;
end;

end.

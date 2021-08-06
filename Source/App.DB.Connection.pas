{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Connection;

interface

uses
  System.Classes, System.SysUtils, System.Variants,
  {$IFDEF FIREDAC}FireDAC.Comp.UI, FireDAC.Stan.Def,{$ENDIF}
  {$I DB_Links.inc};

{$IFDEF FIREDAC}
const
  ServerParamIndex = 1;
  PortParamIndex = 2;
{$ENDIF}

type
  TCLDBConnectionClass = class of TCLDBConnection;
  TCLSqlOpenType = (sqlNone, sqlOpen, sqlExec);
  TCLConnectionStatus = (cnNone, cnDisconnect, cnReconnect, cnConnect);
  TConnectionStatusChangeEvent = procedure(Sender: TObject; const Status: TCLConnectionStatus) of object;

  TCLDBConnection = class(TComponent)
  private
    FOnConnectionStatusChange: TConnectionStatusChangeEvent;

    procedure BeforeConnect(Sender: TObject);
    procedure AfterConnect(Sender: TObject);
    procedure AfterDisconnect(Sender: TObject);

    procedure SetParamsToQuery(var Query: TDBQuery; const ParamNames: array of string;
      const ParamValues: array of Variant);

    function InternalCreateQuery(const Owner: TComponent; const SqlText: string;
      const ParamNames: array of string; const ParamValues: array of Variant): TDBQuery;

  {$IFDEF FIREDAC}
    function GetValueFromServerParam(Index: Integer): string;
    procedure SetValueToServerParam(Index: Integer; const Value: string);
  {$ENDIF}

    procedure DoConnectionStatusChange(const Status: TCLConnectionStatus);
    function GetServer: string;
    procedure SetServer(const Value: string);
    function GetDatabase: string;
    procedure SetDatabase(const Value: string);
    function GetUserName: string;
    procedure SetUserName(const Value: string);
    function GetPassword: string;
    procedure SetPassword(const Value: string);
    function GetConnectionString: string;
    procedure SetConnectionString(const Value: string);
    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    procedure SetConnectionStatus(const Value: TCLConnectionStatus);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
  {$IFDEF FIREDAC}
    function GetInternalServer: string;
    procedure SetInternalServer(const Value: string);
    function GetInternalPort: Integer;
    procedure SetInternalPort(const Value: Integer);
  {$ENDIF}
  protected
    FConnection: TDBConnection;
  {$IFDEF FIREDAC}
    FTransaction: TFDTransaction;
    FErrorDialog: TFDGUIxErrorDialog;
    FWaitCursor: TFDGUIxWaitCursor;
  {$ENDIF}
    FConnectionStatus: TCLConnectionStatus;

    procedure DoConnect(const Connection: TDBConnection); virtual; abstract;

  {$IFDEF FIREDAC}
    property InternalServer: string read GetInternalServer write SetInternalServer;
    property InternalPort: Integer read GetInternalPort write SetInternalPort;
  {$ENDIF}

    function GetDefaultPort: Integer; virtual;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure Connect(const Server, DataBase, UserName, Password: string; Port: Integer); overload;
    procedure Connect; overload;
    procedure Disconnect;

    function IsTableExists(const TableName: string): Boolean; virtual; abstract; 

    {query}
    function CreateQuery(const Owner: TComponent; const SqlText: string;
      const OpenType: TCLSqlOpenType): TDBQuery; overload;
    function CreateQuery(const SqlText: string; const OpenType: TCLSqlOpenType): TDBQuery; overload;
    function CreateQuery(const SqlText: string): TDBQuery; overload;
    function CreateQuery(const Owner: TComponent): TDBQuery; overload;
    {param query}
    function CreateParamQuery(const Owner: TComponent; const SqlText: string;
      const ParamNames: array of string; const ParamValues: array of Variant;
      const OpenType: TCLSqlOpenType): TDBQuery; overload;
    function CreateParamQuery(const SqlText: string; const ParamNames: array of string;
      const ParamValues: array of Variant; const OpenType: TCLSqlOpenType): TDBQuery; overload;
    function CreateParamQuery(const SqlText: string; const ParamNames: array of string;
      const ParamValues: array of Variant): TDBQuery; overload;
    {exec query}
    procedure ExecSql(const SqlText: string; const ParamNames: array of string;
      const ParamValues: array of Variant); overload;
    procedure ExecSql(const SqlText: string); overload;

    function CreateStoredProc(const StoredProcName: string): TDBStoredProc;

    procedure StartTransaction();
    procedure CommitTransaction();
    procedure RollbackTransaction();

    procedure BackupDataBase(const FileName: string); virtual; abstract;
    procedure RestoreDataBase(const FileName: string); virtual; abstract;

    function ConnectionStatusToStr(const Value: TCLConnectionStatus): string;

    property Connection: TDBConnection read FConnection;
    property Connected: Boolean read GetConnected write SetConnected;
    property Server: string read GetServer write SetServer;
    property Database: string read GetDatabase write SetDatabase;
    property UserName: string read GetUserName write SetUserName;
    property Password: string read GetPassword write SetPassword;
    property Port: Integer read GetPort write SetPort;
    property DefaultPort: Integer read GetDefaultPort;
    property ConnectionStatus: TCLConnectionStatus read FConnectionStatus;
    property ConnectionString: string read GetConnectionString write SetConnectionString;
    property OnConnectionStatusChange: TConnectionStatusChangeEvent read FOnConnectionStatusChange write FOnConnectionStatusChange;
  end;

implementation

{ TCLConnection }

constructor TCLDBConnection.Create(Owner: TComponent);
begin
  inherited;

  FConnectionStatus := cnNone;

  FConnection := TDBConnection.Create(Self);
{$IFDEF FIREDAC}
  FTransaction := TFDTransaction.Create(Self);
  FErrorDialog := TFDGUIxErrorDialog.Create(Self);
  FWaitCursor := TFDGUIxWaitCursor.Create(Self);

  FConnection.Transaction := FTransaction;
  FTransaction.Connection := FConnection;
{$ENDIF}

  FConnection.BeforeConnect := BeforeConnect;
  FConnection.AfterConnect := AfterConnect;
  FConnection.AfterDisconnect := AfterDisconnect;
end;

destructor TCLDBConnection.Destroy;
begin
  FConnection.BeforeConnect := nil;
  FConnection.AfterConnect := nil;
  FConnection.AfterDisconnect := nil;

  inherited;
end;

procedure TCLDBConnection.BeforeConnect(Sender: TObject);
begin
  SetConnectionStatus(cnReconnect);
end;

procedure TCLDBConnection.AfterConnect(Sender: TObject);
begin
  SetConnectionStatus(cnConnect);
end;

procedure TCLDBConnection.AfterDisconnect(Sender: TObject);
begin
  SetConnectionStatus(cnDisconnect);
end;

procedure TCLDBConnection.SetParamsToQuery(var Query: TDBQuery;
  const ParamNames: array of string; const ParamValues: array of Variant);
var
  i: Integer;
  Param: string;
  Value: Variant;
begin
  for i := 0 to High(ParamNames) do
  begin
    Param := Trim(ParamNames[i]);
    Value := ParamValues[i];
    if (Param = '') then
      Continue;

    if VarIsEmpty(Value) or VarIsNull(Value) then
      Query.ParamByName(Param).Clear
    else
      Query.ParamByName(Param).Value := Value;
  end;
end;

function TCLDBConnection.InternalCreateQuery(const Owner: TComponent;
  const SqlText: string; const ParamNames: array of string;
  const ParamValues: array of Variant): TDBQuery;
begin
  Result := TDBQuery.Create(Owner);
  try
    Result.Connection := FConnection;
    Result.SQL.Text := SqlText;
    SetParamsToQuery(Result, ParamNames, ParamValues);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

{$IFDEF FIREDAC}
function TCLDBConnection.GetValueFromServerParam(Index: Integer): string;
var
  Params: TStringList;
begin
  Params := TStringList.Create;
  try
    Params.CommaText := FConnection.Params.Values['Server'];
    if Params.Count < Index then
      Result := ''
    else
      Result := Params[Index - 1];
  finally
    Params.Free;
  end;
end;

procedure TCLDBConnection.SetValueToServerParam(Index: Integer; const Value: string);
var
  Params: TStringList;
begin
  Params := TStringList.Create;
  try
    Params.CommaText := FConnection.Params.Values['Server'];

    while Index > Params.Count do
      Params.Add('');

    Params[Index - 1] := Value;
    FConnection.Params.Values['Server'] := Params.CommaText;
  finally
    Params.Free;
  end;
end;
{$ENDIF}

procedure TCLDBConnection.DoConnectionStatusChange(const Status: TCLConnectionStatus);
begin
  if Assigned(FOnConnectionStatusChange) then
    FOnConnectionStatusChange(Self, Status);
end;

function TCLDBConnection.GetServer: string;
begin
{$IFDEF FIREDAC}
  Result := InternalServer;
{$ENDIF}
{$IFDEF UNIDAC}
  Result := FConnection.Server;
{$ENDIF}
end;

procedure TCLDBConnection.SetServer(const Value: string);
begin
  if CompareText(Server, Value) <> 0 then
  {$IFDEF FIREDAC}
    InternalServer := Value
  {$ENDIF}
  {$IFDEF UNIDAC}
    FConnection.Server := Value;
  {$ENDIF}
end;

function TCLDBConnection.GetDatabase: string;
begin
{$IFDEF FIREDAC}
  Result := FConnection.Params.Values['Database'];
{$ENDIF}
{$IFDEF UNIDAC}
  Result := FConnection.Database;
{$ENDIF}
end;

procedure TCLDBConnection.SetDatabase(const Value: string);
begin
  if CompareText(Database, Value) <> 0 then
  {$IFDEF FIREDAC}
    FConnection.Params.Values['Database'] := Value
  {$ENDIF}
  {$IFDEF UNIDAC}
    FConnection.Database := Value;
  {$ENDIF}
end;

function TCLDBConnection.GetUserName: string;
begin
{$IFDEF FIREDAC}
  Result := FConnection.Params.Values['User_Name'];
{$ENDIF}
{$IFDEF UNIDAC}
  Result := FConnection.Username;
{$ENDIF}
end;

procedure TCLDBConnection.SetUserName(const Value: string);
begin
  if CompareText(Username, Value) <> 0 then
  {$IFDEF FIREDAC}
    FConnection.Params.Values['User_Name'] := Value
  {$ENDIF}
  {$IFDEF UNIDAC}
    FConnection.Username := Value;
  {$ENDIF}
end;

function TCLDBConnection.GetPassword: string;
begin
{$IFDEF FIREDAC}
  Result := FConnection.Params.Values['Password'];
{$ENDIF}
{$IFDEF UNIDAC}
  Result := FConnection.Password;
{$ENDIF}
end;

procedure TCLDBConnection.SetPassword(const Value: string);
begin
  if CompareText(Password, Value) <> 0 then
  {$IFDEF FIREDAC}
    FConnection.Params.Values['Password'] := Value
  {$ENDIF}
  {$IFDEF UNIDAC}
    FConnection.Password := Value;
  {$ENDIF}
end;

function TCLDBConnection.GetPort: Integer;
begin
{$IFDEF FIREDAC}
  Result := InternalPort;
{$ENDIF}
{$IFDEF UNIDAC}
  Result := FConnection.Port;
{$ENDIF}
end;

procedure TCLDBConnection.SetPort(const Value: Integer);
begin
  if Port <> Value then
  {$IFDEF FIREDAC}
    InternalPort := Value
  {$ENDIF}
  {$IFDEF UNIDAC}
    FConnection.Port := Value;
  {$ENDIF}
end;

function TCLDBConnection.GetDefaultPort: Integer;
begin
  Result := 0;
end;

{$IFDEF FIREDAC}
function TCLDBConnection.GetInternalServer: string;
begin
  Result := GetValueFromServerParam(ServerParamIndex);
end;

procedure TCLDBConnection.SetInternalServer(const Value: string);
begin
  SetValueToServerParam(ServerParamIndex, Value);
end;

function TCLDBConnection.GetInternalPort: Integer;
var
  Port: string;
begin
  Port := GetValueFromServerParam(PortParamIndex);
  if not TryStrToInt(Port, Result) then
    Result := 0;
end;

procedure TCLDBConnection.SetInternalPort(const Value: Integer);
begin
  if (Value > 0) and (Value = DefaultPort) then
    SetValueToServerParam(PortParamIndex, IntToStr(Value))
  else
    SetValueToServerParam(ServerParamIndex, Server);
end;
{$ENDIF}

function TCLDBConnection.GetConnectionString: string;

  procedure ParamAdd(const Name, Value: string; var Params: TStringList);
  begin
    if Trim(Value) <> '' then
      Params.Add(Format('%s=%s', [Name, Value]));
  end;

var
  Params: TStringList;
begin
  Params := TStringList.Create;
  try
    Params.Delimiter := ';';
    ParamAdd('Server', Server, Params);
    ParamAdd('Database', Database, Params);
    ParamAdd('UID', UserName, Params);
    ParamAdd('PWD', Password, Params);

    Result := Params.DelimitedText;
  finally
    Params.Free;
  end;
end;

procedure TCLDBConnection.SetConnectionString(const Value: string);

  function GetValue(const Name: string; Params: TStringList): string;
  var
    Index: Integer;
  begin
    Result := '';

    Index := Params.IndexOfName(Name);
    if Index >= 0 then
      Result := Params.ValueFromIndex[Index];
  end;

var
  Params: TStringList;
begin
  if Value = ConnectionString then
    Exit;

  Params := TStringList.Create;
  try
    Params.Delimiter := ';';
    Params.DelimitedText := Value;

    Server := GetValue('Server', Params);
    Database := GetValue('Database', Params);
    UserName := GetValue('UID', Params);
    Password := GetValue('PWD', Params);
  finally
    Params.Free;
  end;
end;

function TCLDBConnection.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TCLDBConnection.SetConnected(const Value: Boolean);
begin
  if Value then
    Connect
  else
    Disconnect;
end;

procedure TCLDBConnection.SetConnectionStatus(const Value: TCLConnectionStatus);
begin
  if FConnectionStatus <> Value then
  begin
    FConnectionStatus := Value;
    DoConnectionStatusChange(Value);
  end;
end;

procedure TCLDBConnection.Connect(const Server, DataBase, UserName, Password: string; Port: Integer);
begin
  if FConnection.Connected then
    Exit;

  {устанавливаем настройки подключения к БД}
  Self.Server := Server;
  Self.Database := DataBase;
  Self.UserName := UserName;
  Self.Password := Password;
  Self.Port := Port;

  DoConnect(FConnection);

  if not Connected then
    raise Exception.Create('Подключение к БД не выполнено');
end;

procedure TCLDBConnection.Connect;
begin
  Connect(Server, DataBase, UserName, Password, Port);
end;

procedure TCLDBConnection.Disconnect;
begin
  FConnection.Connected := False;
end;

function TCLDBConnection.CreateQuery(const Owner: TComponent;
  const SqlText: string; const OpenType: TCLSqlOpenType): TDBQuery;
begin
  Result := CreateParamQuery(Owner, SqlText, [], [], OpenType);
end;

function TCLDBConnection.CreateQuery(const SqlText: string;
  const OpenType: TCLSqlOpenType): TDBQuery;
begin
  Result := CreateQuery(nil, SqlText, OpenType);
end;

function TCLDBConnection.CreateQuery(const SqlText: string): TDBQuery;
begin
  Result := CreateQuery(nil, SqlText, sqlOpen);
end;

function TCLDBConnection.CreateQuery(const Owner: TComponent): TDBQuery;
begin
  Result := CreateQuery(Owner, '', sqlNone);
end;

function TCLDBConnection.CreateParamQuery(const Owner: TComponent;
  const SqlText: string; const ParamNames: array of string;
  const ParamValues: array of Variant; const OpenType: TCLSqlOpenType): TDBQuery;
begin
  Result := InternalCreateQuery(Owner, SqlText, ParamNames, ParamValues);
  try
    case OpenType of
      sqlOpen:
        Result.Open;
      sqlExec:
        Result.ExecSQL;
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TCLDBConnection.CreateParamQuery(const SqlText: string;
  const ParamNames: array of string; const ParamValues: array of Variant;
  const OpenType: TCLSqlOpenType): TDBQuery;
begin
  Result := CreateParamQuery(nil, SqlText, ParamNames, ParamValues, OpenType);
end;

function TCLDBConnection.CreateParamQuery(const SqlText: string;
  const ParamNames: array of string;
  const ParamValues: array of Variant): TDBQuery;
begin
  Result := CreateParamQuery(nil, SqlText, ParamNames, ParamValues, sqlOpen);
end;

procedure TCLDBConnection.ExecSql(const SqlText: string;
  const ParamNames: array of string; const ParamValues: array of Variant);
var
  Q: TDBQuery;
begin
  Q := CreateParamQuery(SqlText, ParamNames, ParamValues, sqlNone);
  try
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TCLDBConnection.ExecSql(const SqlText: string);
begin
  ExecSql(SqlText, [], []);
end;

function TCLDBConnection.CreateStoredProc(const StoredProcName: string): TDBStoredProc;
begin
  Result := TDBStoredProc.Create(Self);
  Result.Connection := FConnection;
  Result.StoredProcName := StoredProcName;
end;

procedure TCLDBConnection.StartTransaction;
begin
  if not Connection.InTransaction then
    Connection.StartTransaction;
end;

procedure TCLDBConnection.CommitTransaction;
begin
  if Connection.InTransaction then
    Connection.Commit;
end;

procedure TCLDBConnection.RollbackTransaction;
begin
  if Connection.InTransaction then
    Connection.Rollback;
end;

function TCLDBConnection.ConnectionStatusToStr(const Value: TCLConnectionStatus): string;
begin
  case Value of
    cnDisconnect:
      Result := 'Нет подключения';
    cnReconnect:
      Result := 'Подключение';
    cnConnect:
      Result := 'Есть подключение';
    else
      Result := 'Не определен';
  end;
end;

end.

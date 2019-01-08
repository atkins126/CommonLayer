{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DBConnection;

interface

uses
  System.Classes, System.SysUtils, System.Variants, FireDAC.Comp.Client,
  FireDAC.Comp.UI;

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

    procedure SetParamsToQuery(var Query: TFDQuery; const ParamNames: array of String;
      const ParamValues: array of Variant);

    function InternalCreateQuery(const Owner: TComponent; const SqlText: String;
      const ParamNames: array of String; const ParamValues: array of Variant): TFDQuery;

    procedure DoConnectionStatusChange(const Status: TCLConnectionStatus);
    function GetServer: String;
    procedure SetServer(const Value: String);
    function GetDatabase: string;
    procedure SetDatabase(const Value: string);
    function GetUserName: String;
    procedure SetUserName(const Value: String);
    function GetPassword: String;
    procedure SetPassword(const Value: String);
    function GetConnectionString: String;
    procedure SetConnectionString(const Value: String);
    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
  protected
    FConnection: TFDConnection;
    FTransaction: TFDTransaction;
    FErrorDialog: TFDGUIxErrorDialog;
    FWaitCursor: TFDGUIxWaitCursor;
    FConnectionStatus: TCLConnectionStatus;

    procedure DoConnect(const Connection: TFDConnection); virtual; abstract;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure Connect(const Server, DataBase, UserName, Password: string); overload;
    procedure Connect(); overload;
    procedure Disconnect();

    {query}
    function CreateQuery(const Owner: TComponent; const SqlText: String;
      const OpenType: TCLSqlOpenType): TFDQuery; overload;
    function CreateQuery(const SqlText: String; const OpenType: TCLSqlOpenType): TFDQuery; overload;
    function CreateQuery(const SqlText: String): TFDQuery; overload;
    {param query}
    function CreateParamQuery(const Owner: TComponent; const SqlText: String;
      const ParamNames: array of String; const ParamValues: array of Variant;
      const OpenType: TCLSqlOpenType): TFDQuery; overload;
    function CreateParamQuery(const SqlText: String; const ParamNames: array of String;
      const ParamValues: array of Variant; const OpenType: TCLSqlOpenType): TFDQuery; overload;
    function CreateParamQuery(const SqlText: String; const ParamNames: array of String;
      const ParamValues: array of Variant): TFDQuery; overload;
    {exec query}
    procedure ExecSql(const SqlText: String; const ParamNames: array of String;
      const ParamValues: array of Variant); overload;
    procedure ExecSql(const SqlText: String); overload;

    procedure StartTransaction();
    procedure CommitTransaction();
    procedure RollbackTransaction();

    procedure BackupDataBase(const FileName: String); virtual; abstract;
    procedure RestoreDataBase(const FileName: String); virtual; abstract;

    function ConnectionStatusToStr(const Value: TCLConnectionStatus): string;

    property Connected: Boolean read GetConnected write SetConnected;
    property Server: string read GetServer write SetServer;
    property Database: string read GetDatabase write SetDatabase;
    property UserName: String read GetUserName write SetUserName;
    property Password: String read GetPassword write SetPassword;
    property ConnectionStatus: TCLConnectionStatus read FConnectionStatus;
    property ConnectionString: String read GetConnectionString write SetConnectionString;
    property OnConnectionStatusChange: TConnectionStatusChangeEvent read FOnConnectionStatusChange write FOnConnectionStatusChange;
  end;

implementation

{ TCLConnection }

constructor TCLDBConnection.Create(Owner: TComponent);
begin
  inherited;

  FConnectionStatus := cnNone;

  FConnection := TFDConnection.Create(Self);
  FTransaction := TFDTransaction.Create(Self);
  FErrorDialog := TFDGUIxErrorDialog.Create(Self);
  FWaitCursor := TFDGUIxWaitCursor.Create(Self);

  FConnection.Transaction := FTransaction;
  FTransaction.Connection := FConnection;

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
  DoConnectionStatusChange(cnReconnect);
end;

procedure TCLDBConnection.AfterConnect(Sender: TObject);
begin
  DoConnectionStatusChange(cnConnect);
end;

procedure TCLDBConnection.AfterDisconnect(Sender: TObject);
begin
  DoConnectionStatusChange(cnDisconnect);
end;

procedure TCLDBConnection.SetParamsToQuery(var Query: TFDQuery;
  const ParamNames: array of String; const ParamValues: array of Variant);
var
  i: Integer;
  Param: String;
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
  const SqlText: String; const ParamNames: array of String;
  const ParamValues: array of Variant): TFDQuery;
begin
  Result := TFDQuery.Create(Owner);
  try
    Result.Connection := FConnection;
    Result.SQL.Text := SqlText;
    SetParamsToQuery(Result, ParamNames, ParamValues);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TCLDBConnection.DoConnectionStatusChange(const Status: TCLConnectionStatus);
begin
  if Assigned(FOnConnectionStatusChange) then
    FOnConnectionStatusChange(Self, Status);
end;

function TCLDBConnection.GetServer: String;
begin
  Result := FConnection.Params.Values['Server'];
end;

procedure TCLDBConnection.SetServer(const Value: String);
begin
  if CompareText(Database, Value) <> 0 then
    FConnection.Params.Values['Server'] := Value;
end;

function TCLDBConnection.GetDatabase: string;
begin
  Result := FConnection.Params.Values['Database'];
end;

procedure TCLDBConnection.SetDatabase(const Value: string);
begin
  if CompareText(Database, Value) <> 0 then
    FConnection.Params.Values['Database'] := Value;
end;

function TCLDBConnection.GetUserName: String;
begin
  Result := FConnection.Params.Values['User_Name'];
end;

procedure TCLDBConnection.SetUserName(const Value: String);
begin
  if CompareText(Database, Value) <> 0 then
    FConnection.Params.Values['User_Name'] := Value;
end;

function TCLDBConnection.GetPassword: String;
begin
  Result := FConnection.Params.Values['Password'];
end;

procedure TCLDBConnection.SetPassword(const Value: String);
begin
  if CompareText(Database, Value) <> 0 then
    FConnection.Params.Values['Password'] := Value;
end;

function TCLDBConnection.GetConnectionString: String;

  procedure ParamAdd(const Name, Value: String; var Params: TStringList);
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

procedure TCLDBConnection.SetConnectionString(const Value: String);

  function GetValue(const Name: String; Params: TStringList): String;
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
  FConnection.Connected := Value;
end;

procedure TCLDBConnection.Connect(const Server, DataBase, UserName, Password: string);
begin
  if FConnection.Connected then
    Exit;

  {устанавливаем настройки подключения к БД}
  Self.Server := Server;
  Self.Database := DataBase;
  Self.UserName := UserName;
  Self.Password := Password;

  DoConnect(FConnection);
end;

procedure TCLDBConnection.Connect();
begin
  Connect(Server, DataBase, UserName, Password);
end;

procedure TCLDBConnection.Disconnect();
begin
  FConnection.Connected := False;
end;

function TCLDBConnection.CreateQuery(const Owner: TComponent;
  const SqlText: String; const OpenType: TCLSqlOpenType): TFDQuery;
begin
  Result := CreateParamQuery(Owner, SqlText, [], [], OpenType);
end;

function TCLDBConnection.CreateQuery(const SqlText: String;
  const OpenType: TCLSqlOpenType): TFDQuery;
begin
  Result := CreateQuery(nil, SqlText, OpenType);
end;

function TCLDBConnection.CreateQuery(const SqlText: String): TFDQuery;
begin
  Result := CreateQuery(nil, SqlText, sqlOpen);
end;

function TCLDBConnection.CreateParamQuery(const Owner: TComponent;
  const SqlText: String; const ParamNames: array of String;
  const ParamValues: array of Variant; const OpenType: TCLSqlOpenType): TFDQuery;
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

function TCLDBConnection.CreateParamQuery(const SqlText: String;
  const ParamNames: array of String; const ParamValues: array of Variant;
  const OpenType: TCLSqlOpenType): TFDQuery;
begin
  Result := CreateParamQuery(nil, SqlText, ParamNames, ParamValues, OpenType);
end;

function TCLDBConnection.CreateParamQuery(const SqlText: String;
  const ParamNames: array of String;
  const ParamValues: array of Variant): TFDQuery;
begin
  Result := CreateParamQuery(nil, SqlText, ParamNames, ParamValues, sqlOpen);
end;

procedure TCLDBConnection.ExecSql(const SqlText: String;
  const ParamNames: array of String; const ParamValues: array of Variant);
var
  Q: TFDQuery;
begin
  Q := CreateParamQuery(SqlText, ParamNames, ParamValues, sqlNone);
  try
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TCLDBConnection.ExecSql(const SqlText: String);
begin
  ExecSql(SqlText, [], []);
end;

procedure TCLDBConnection.StartTransaction;
begin
  if not FTransaction.Active then
    FTransaction.StartTransaction;
end;

procedure TCLDBConnection.CommitTransaction;
begin
  if FTransaction.Active then
    FTransaction.Commit;
end;

procedure TCLDBConnection.RollbackTransaction;
begin
  if FTransaction.Active then
    FTransaction.Rollback;
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

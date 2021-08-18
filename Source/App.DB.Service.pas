{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Service;

interface

uses
  System.Classes, System.SysUtils, System.Variants, App.DB.Entity, App.DB.DAO,
  App.DB.Connection;

type
  TInformationMessage = procedure(Sender: TObject; Value: string) of object;
  TConfirmationMessage = procedure(Sender: TObject; Value: string; var Accept: Boolean) of object;
  TErrorMessage = procedure(Sender: TObject; Value: string) of object;

  TServiceCommon = class(TObject)
  private
  protected
    FConnection: TCLDBConnection;
    FDAO: TDAOCommon;

    function GetDAOClass(): TDAOClass; virtual; abstract;

    {сообщение кот. выводится при удалении записи}
    function GetDeleteMessage(const Entity: TEntity): string; virtual;

    {проверка, можно удалять запись}
    function CanDelete(const Entity: TEntity; var vMessage: string): Boolean; virtual;
  public
    constructor Create(const Connection: TCLDBConnection);
    destructor Destroy; override;

    procedure Add(const Entity: TEntity); virtual;
    procedure Edit(const Entity: TEntity); virtual;
    procedure Save(const Entity: TEntity; const InTransaction: Boolean = True); virtual;

    {удалить запись}
    {VerifyCanRemove = True - необходимо выполнить проверку возможности удалять запись}
    {WithConfirm = True - запрос подтверждения на удаление записи}
    function Remove(const Entity: TEntity; const VerifyCanRemove, WithConfirm: Boolean): Boolean; virtual;

    {получение записи по ключевому полю}
    function GetAt(const ID: Integer): TEntity; virtual;

    {получение нового объекта}
    function GetNewInstance(): TEntity; virtual;

    procedure StartTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
  end;

implementation

uses
  App.SysUtils;

{ TServiceCommon }

constructor TServiceCommon.Create(const Connection: TCLDBConnection);
begin
  inherited Create();

  FConnection := Connection;
  FDAO := GetDAOClass.Create(Connection);
end;

destructor TServiceCommon.Destroy;
begin
  FreeAndNil(FDAO);

  inherited;
end;

function TServiceCommon.GetDeleteMessage(const Entity: TEntity): string;
begin
  Result := '';
end;

function TServiceCommon.CanDelete(const Entity: TEntity; var vMessage: string): Boolean;
begin
  vMessage := '';
  Result := not FDAO.RecordUsed(Entity);
  if not Result then
    vMessage := 'Удаление запрещено. Есть данные ссылающиеся на запись';
end;

procedure TServiceCommon.Add(const Entity: TEntity);
begin
  FDAO.Insert(Entity);
end;

procedure TServiceCommon.Edit(const Entity: TEntity);
begin
  FDAO.Update(Entity);
end;

procedure TServiceCommon.Save(const Entity: TEntity; const InTransaction: Boolean = True);
begin
  if InTransaction then
    StartTransaction;

  try
    {если не означен ID записи}
    if IsNullID(Entity.ID) then
      Add(Entity)
    else
      Edit(Entity);

    if InTransaction then
      CommitTransaction;
  except
    if InTransaction then
      RollbackTransaction;

    raise;
  end;
end;

function TServiceCommon.Remove(const Entity: TEntity; const VerifyCanRemove, WithConfirm: Boolean): Boolean;
var
  Caption: string;
begin
  if (not VerifyCanRemove) or CanDelete(Entity, Caption) then begin
    {получение сообщение кот. выводится при удалении записи}
    Caption := GetDeleteMessage(Entity);

    {если нет собщения}
    if Caption = '' then
      Caption:= 'Удалить текущую запись';

  {$IFDEF CARDS}
    {если необходимо выводить подтверждение удаления записи}
    if WithConfirm then
      Result:= Confirm(Caption)
    else
  {$ENDIF}
      Result := True;

    if Result then
      FDAO.Remove(Entity);
  end
{$IFDEF CARDS}
  else
    ErrorMessage(Caption)
{$ENDIF};
end;

function TServiceCommon.GetAt(const ID: Integer): TEntity;
begin
  Result := FDAO.GetAt(ID);
end;

function TServiceCommon.GetNewInstance(): TEntity;
begin
  Result := FDAO.GetNewInstance;
end;

procedure TServiceCommon.StartTransaction;
begin
  FConnection.StartTransaction;
end;

procedure TServiceCommon.CommitTransaction;
begin
  FConnection.CommitTransaction;
end;

procedure TServiceCommon.RollbackTransaction;
begin
  FConnection.RollbackTransaction;
end;

end.

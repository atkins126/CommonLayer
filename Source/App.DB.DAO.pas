{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.DAO;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Data.DB,  App.DB.Connection,
  App.DB.Entity , App.DB.MetaData, App.DB.Utils,
  {$I DB_Links.inc};

const
  MODIFY_TYPE_INSERT_IDX = 1; {���������� ������}
  MODIFY_TYPE_UPDATE_IDX = 2; {��������� ������}
  MODIFY_TYPE_REMOVE_IDX = 3; {�������� ������}

type
//   TModifyType = (mdtInsert, {���������� ������}
//                  mdtUpdate, {��������� ������}
//                  mdtDelete, {������� � �������� ������}
//                  mdtRemove {�������� ������} );

  TAfterUpdateEvent = procedure(const Entity: TEntity; const ModifyType: Integer) of object;
  TDAOClass = class of TDAOCommon;

  TDAOCommon = class(TObject)
  private
    FMetaData: TMetaData;

    {������� - ���������� ������}
    FOnAfterUpdate: TAfterUpdateEvent;
  protected
    FConnection: TCLDBConnection;

    function EntityClass: TEntityClass; virtual; abstract;

    {������������� ������� - ���������� ������}
    procedure DoAfterUpdate(const Entity: TEntity; const ModifyType: Integer);

    {���������� �������� ������}
    procedure RemoveAction(const Entity: TEntity); virtual;
  public
    constructor Create(const Connection: TCLDBConnection);
    destructor Destroy; override;

    procedure Insert(const Entity: TEntity); virtual;
    procedure Update(const Entity: TEntity); virtual;
    procedure Remove(const Entity: TEntity); virtual;
    function GetAt(const ID: Integer): TEntity; virtual;

    function GetNewInstance: TEntity; virtual; //CreateInstance

    {�� ������ ���� ������}
    function RecordUsed(const Entity: TEntity): Boolean; virtual;

   {������� - ���������� ������}
    property OnAfterUpdate: TAfterUpdateEvent read FOnAfterUpdate write FOnAfterUpdate;
  end;

implementation

uses
  App.SysUtils;

{ TDAOCommon }

constructor TDAOCommon.Create(const Connection: TCLDBConnection);
begin
  inherited Create();

  FConnection := Connection;
  FMetaData := TMetaData.Create(EntityClass);
end;

destructor TDAOCommon.Destroy;
begin
  FOnAfterUpdate := nil;
  FConnection := nil;
  FMetaData.Free;

  inherited;
end;

procedure TDAOCommon.DoAfterUpdate(const Entity: TEntity; const ModifyType: Integer);
begin
  {���� ���������� ��������, �� ��������� ���}
  if Assigned(FOnAfterUpdate) then
    FOnAfterUpdate(Entity, ModifyType);
end;

procedure TDAOCommon.RemoveAction(const Entity: TEntity);
begin
  FConnection.ExecSql(
    ' DELETE FROM ' + FMetaData.EntityName + ' WHERE ID = :EntityID ',
    ['EntityID'],
    [IsNull(Entity.ID, 0)]);
end;

procedure TDAOCommon.Insert(const Entity: TEntity);
//var
//  Q: TDBQuery;
//  SqlText: string;
//  KeyFields: string;
begin
//  KeyFields := FEntityInfo.GetKeyFieldList;
//  SqlText := Format('INSERT INTO %s (%s) VALUES (%s) RETURNING %s',
//                    [FEntityInfo.EntityName,
//                     FEntityInfo.GetFieldList,
//                     FEntityInfo.GetFieldList(':'),
//                     KeyFields]);
//  Q := dmConnection.CreateQuery(SqlText, sqlNone);
//  try
//    FEntityInfo.SetParamValues(Entity, Q.Params);
//    Q.Open;
//    FEntityInfo.SetValues(Entity, KeyFields, Q);
//  finally
//    Q.Free;
//  end;

  DoAfterUpdate(Entity, MODIFY_TYPE_INSERT_IDX);
end;

 procedure TDAOCommon.Update(const Entity: TEntity);
begin
  DoAfterUpdate(Entity, MODIFY_TYPE_UPDATE_IDX);
end;

procedure TDAOCommon.Remove(const Entity: TEntity);
begin
  RemoveAction(Entity);
  DoAfterUpdate(Entity, MODIFY_TYPE_REMOVE_IDX);
end;

function TDAOCommon.GetAt(const ID: Integer): TEntity;
var
  Q: TDBQuery;
  SqlText: string;
begin
  Result := nil;

  SqlText := Format('SELECT %s FROM %s WHERE ID = :EntityID',
                    [FMetaData.GetAllFieldList(''), FMetaData.EntityName]);

  Q := FConnection.CreateParamQuery(SqlText, ['EntityID'], [ID]);
  try
    if Q.Eof then
      raise Exception.Create('������ [' + EntityClass.ClassName + '] #' + IntToStr(ID) + ' �� �������');;

    Result := EntityClass.Create;
    FMetaData.SetValues(Result, Q);
  finally
    Q.Free;
  end;
end;

function TDAOCommon.GetNewInstance(): TEntity;
begin
  Result := EntityClass.Create;
end;

function TDAOCommon.RecordUsed(const Entity: TEntity): Boolean;
begin
  Result := False;
end;

end.

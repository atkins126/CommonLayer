{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.MetaData;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Data.DB, Generics.Collections,
  System.TypInfo, System.RTTI, App.DB.Columns, App.DB.Entity;

type
  TStringArray = array of string;

  TMetaData = class
  private
    FEntityClass: TEntityClass;
    FEntityName: string;
    FFields: THFields;
  protected
    procedure Load(); virtual;
  public
    constructor Create(const EntityClass: TEntityClass); virtual;
    destructor Destroy(); override;

    function GetFieldList(const Prefix: string): string; overload;
    function GetFieldList: string; overload;
    function GetKeyFieldList(const Prefix: string): string; overload;
    function GetKeyFieldList: string; overload;
    function GetAllFieldList(const Prefix: string): string; overload;
    function GetAllFieldList: string; overload;

    procedure SetValues(Entity: TPersistent; DataSet: TDataSet); overload;
    procedure SetValues(Entity: TPersistent; const Names: string; DataSet: TDataSet); overload;
    procedure SetParamValues(Entity: TPersistent; Params: TParams);
//    function GetFieldValues():

    property EntityName: string read FEntityName;
//    property FieldsCount: Integer read GetFieldsCount;
  end;

implementation

{ TMetaData }

constructor TMetaData.Create(const EntityClass: TEntityClass);
begin
  FEntityName := '';
  FEntityClass := EntityClass;
  FFields := THFields.Create;

  Load();
end;

destructor TMetaData.Destroy;
begin
  FFields.Free;

  inherited;
end;

procedure TMetaData.Load;
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  Attribute: TCustomAttribute;
  oProperty: TRttiProperty;
  Item: THField;
  IsKey: Boolean;
begin
  FFields.Clear;

  RttiContext := TRttiContext.Create;
  try
    RttiType := RttiContext.GetType(TPersistentClass(FEntityClass).ClassInfo);
    for Attribute in RttiType.GetAttributes do
    begin
      if Attribute is TEntityAttribute then
        FEntityName := TEntityAttribute(Attribute).Name;
    end;

    if (FEntityName = '') then
      raise Exception.Create('Для сущности ' + FEntityClass.ClassName + ' не установлен параметр имени таблицы');

    for oProperty in RttiType.GetProperties do
    begin
      Item := nil;
      IsKey := False;

      for Attribute in oProperty.GetAttributes do
      begin
        if (Attribute is TColumnAttribute) then
          Item := THField.Create(oProperty.Name, TColumnAttribute(Attribute).Name)
        else
        if (Attribute is TIDAttribute) then
          IsKey := True;
      end;

      if Item <> nil then
      begin
        if IsKey then
          Item.FieldType := htKeyField;
        FFields.Add(Item);
      end;
    end;
  finally
    RttiContext.Free;
  end;
end;

function TMetaData.GetFieldList(const Prefix: string): string;
begin
  Result := FFields.GetFieldNames(Prefix);
end;

function TMetaData.GetFieldList: string;
begin
  Result := GetFieldList('');
end;

function TMetaData.GetKeyFieldList(const Prefix: string): string;
begin
  Result := FFields.GetKeyFieldNames(Prefix);
end;

function TMetaData.GetKeyFieldList: string;
begin
  Result := GetKeyFieldList('');
end;

function TMetaData.GetAllFieldList(const Prefix: string): string;
begin
  Result := FFields.GetAllFieldNames(Prefix);
end;

function TMetaData.GetAllFieldList: string;
begin
  Result := GetAllFieldList('');
end;

procedure TMetaData.SetValues(Entity: TPersistent; DataSet: TDataSet);
var
  i: Integer;
  Item: THField;
begin
  for i := 0 to FFields.Count - 1 do begin
    Item := FFields.Items[i];
    SetPropValue(Entity, Item.PropertyName, DataSet.FieldByName(Item.FieldName).Value);
  end;
end;

procedure TMetaData.SetValues(Entity: TPersistent; const Names: string;
  DataSet: TDataSet);
var
  i: Integer;
  Field: THField;
  Items: TStringList;
begin
  Items := TStringList.Create;
  try
    Items.CommaText := Names;

    for i := 0  to Items.Count - 1 do begin
      Field := FFields.GetItem(Items[i]);
      SetPropValue(Entity, Field.PropertyName, DataSet.FieldByName(Field.FieldName).Value);
    end;
  finally
    Items.Free;
  end;
end;

procedure TMetaData.SetParamValues(Entity: TPersistent; Params: TParams);
var
  i: Integer;
  Param: TParam;
  Field: THField;
  Value: Variant;
begin
  for i := 0 to Params.Count - 1 do begin
    Param := Params[i];

    Field := FFields.GetItem(Param.Name);
    Value := GetPropValue(Entity, Field.PropertyName);
    if VarIsEmpty(Value) or VarIsNull(Value) then
      Param.Clear
    else
      Param.Value := Value;
  end;
end;

end.

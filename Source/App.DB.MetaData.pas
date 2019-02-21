{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.MetaData;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Data.DB,
  Generics.Collections, System.TypInfo, System.RTTI,
  FireDAC.Stan.Param, App.DB.Columns, App.DB.Entity;

type
  TStringArray = array of String;


  TMetaData = class
  private
    FEntityClass: TEntityClass;
    FEntityName: String;
    FFields: THFields;
  protected
    procedure Load(); virtual;
  public
    constructor Create(const EntityClass: TEntityClass); virtual;
    destructor Destroy(); override;

    function GetFieldList(const Prefix: String): String; overload;
    function GetFieldList(): String; overload;
    function GetKeyFieldList(const Prefix: String): String; overload;
    function GetKeyFieldList(): String; overload;
    function GetAllFieldList(const Prefix: String): String; overload;
    function GetAllFieldList(): String; overload;

    procedure SetValues(Entity: TPersistent; DataSet: TDataSet); overload;
    procedure SetValues(Entity: TPersistent; const Names: String; DataSet: TDataSet); overload;
    procedure SetParamValues(Entity: TPersistent; Params: TFDParams);
//    function GetFieldValues():

    property EntityName: String read FEntityName;
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

function TMetaData.GetFieldList(const Prefix: String): String;
begin
  Result := FFields.GetFieldNames(Prefix);
end;

function TMetaData.GetFieldList(): String;
begin
  Result := GetFieldList('');
end;

function TMetaData.GetKeyFieldList(const Prefix: String): String;
begin
  Result := FFields.GetKeyFieldNames(Prefix);
end;

function TMetaData.GetKeyFieldList(): String;
begin
  Result := GetKeyFieldList('');
end;

function TMetaData.GetAllFieldList(const Prefix: String): String;
begin
  Result := FFields.GetAllFieldNames(Prefix);
end;

function TMetaData.GetAllFieldList(): String;
begin
  Result := GetAllFieldList('');
end;

procedure TMetaData.SetValues(Entity: TPersistent; DataSet: TDataSet);
var
  i: Integer;
  Item: THField;
begin
  for i := 0 to FFields.Count - 1 do
  begin
    Item := FFields.Items[i];
    SetPropValue(Entity, Item.PropertyName, DataSet.FieldByName(Item.FieldName).Value);
  end;
end;

procedure TMetaData.SetValues(Entity: TPersistent; const Names: String;
  DataSet: TDataSet);
var
  i: Integer;
  Field: THField;
  Items: TStringList;
begin
  Items := TStringList.Create;
  try
    Items.CommaText := Names;

    for i := 0  to Items.Count - 1 do
    begin
      Field := FFields.GetItem(Items[i]);
      SetPropValue(Entity, Field.PropertyName, DataSet.FieldByName(Field.FieldName).Value);
    end;
  finally
    Items.Free;
  end;
end;

procedure TMetaData.SetParamValues(Entity: TPersistent; Params: TFDParams);
var
  i: Integer;
  Param: TFDParam;
  Field: THField;
  Value: Variant;
begin
  for i := 0 to Params.Count - 1 do
  begin
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

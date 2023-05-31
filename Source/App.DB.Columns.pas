{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Columns;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Generics.Collections;

type
  THFieldType = (htField, htKeyField);
  THFieldTypes = set of THFieldType;

  THField = class(TPersistent)
  private
    FFieldName: string;
    FPropertyName: string;
    FFieldType: THFieldType;
  public
    constructor Create(const PropertyName, FieldName: string; const FieldType: THFieldType); overload;
    constructor Create(const PropertyName, FieldName: string); overload;

    property FieldName: string read FFieldName write FFieldName;
    property PropertyName: string read FPropertyName write FPropertyName;
    property FieldType: THFieldType read FFieldType write FFieldType;
  end;

  THFields = class
  private
    FItems: TList<THField>;
    FFields: TList<THField>;
    FKeyFields: TList<THField>;
//    FFieldNames: string;

    function GetInternalFields(const Fields: TList<THField>; const Prefix: string): string;
  protected
  public
    constructor Create();
    destructor Destroy; override;

    function Add(const Field: THField): Integer;
    function GetItem(const FieldName: string): THField;
    function Count: Integer;
    function FieldsCount: Integer;
    function KeyFieldsCount: Integer;
    procedure Clear;

    function GetFieldNames(const Prefix: string): string;
    function GetKeyFieldNames(const Prefix: string): string;
    function GetAllFieldNames(const Prefix: string): string;

    property Items: TList<THField> read FItems;
    property Fields: TList<THField> read FFields;
    property KeyFields: TList<THField> read FKeyFields;
  end;

implementation

{ THField }

constructor THField.Create(const PropertyName, FieldName: string; const FieldType: THFieldType);
begin
  inherited Create();

  FFieldName := FieldName;
  FPropertyName := PropertyName;
  FFieldType := FieldType;
end;

constructor THField.Create(const PropertyName, FieldName: string);
begin
  Create(PropertyName, FieldName, htField);
end;

{ THFields }

constructor THFields.Create;
begin
  FItems := TList<THField>.Create;
  FFields := TList<THField>.Create;
  FKeyFields := TList<THField>.Create;
end;

destructor THFields.Destroy;
begin
  Clear;
  FFields.Free;
  FKeyFields.Free;
  FItems.Free;

  inherited;
end;

function THFields.GetInternalFields(const Fields: TList<THField>; const Prefix: string): string;
var
  Item: THField;
begin
  Result := '';
  for Item in Fields do begin
    if Result <> '' then
      Result := Result + ', ';

    Result := Result + Prefix + Item.FieldName;
  end;
end;

function THFields.Add(const Field: THField): Integer;
begin
  Result := FItems.Add(Field);

  if Field.FieldType = htKeyField then
    FKeyFields.Add(Field)
  else
    FFields.Add(Field);
end;

function THFields.GetItem(const FieldName: string): THField;
var
  Item: THField;
begin
  Result := nil;

  for Item in Items do
    if CompareText(Item.FieldName, FieldName) = 0 then
      Exit(Item);
end;

function THFields.Count: Integer;
begin
  Result := FItems.Count;
end;

function THFields.FieldsCount(): Integer;
begin
  Result := FFields.Count;
end;

function THFields.KeyFieldsCount(): Integer;
begin
  Result := FKeyFields.Count;
end;

procedure THFields.Clear;
var
  i: Integer;
begin
  FKeyFields.Clear;
  FFields.Clear;

  for i := 0 to Count - 1 do
    FItems[i].Free;

  FItems.Clear;
end;

function THFields.GetFieldNames(const Prefix: string): string;
begin
  Result := GetInternalFields(FFields, Prefix);
end;

function THFields.GetKeyFieldNames(const Prefix: string): string;
begin
  Result := GetInternalFields(FKeyFields, Prefix);
end;

function THFields.GetAllFieldNames(const Prefix: string): string;
begin
  Result := GetInternalFields(FItems, Prefix);
end;

end.

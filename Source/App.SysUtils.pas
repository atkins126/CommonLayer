{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.SysUtils;

interface

uses
  System.SysUtils, System.Variants;

  {проверяет входной параметр валидность ID}
  function IsNullID(const Value: Variant): Boolean;

  {Если Value = Null, то возвращаем ReplaceValue}
  function IsNull(const Value, ReplaceValue: Variant): Variant;

  {Если Value = NullValue, то возвращаем Null}
  function IfNull(const Value, NullValue: Variant): Variant;

implementation

function IsNullID(const Value: Variant): Boolean;
begin
  Result := VarIsEmpty(Value) or VarIsNull(Value) or
            (VarToStr(Value) = '') or (VarToStr(Value) = '0');
end;

function IsNull(const Value, ReplaceValue: Variant): Variant;
begin
  if Value = Null then
    Result := ReplaceValue
  else
    Result := Value;
end;

function IfNull(const Value, NullValue: Variant): Variant;
begin
  if (Value = NullValue) then
    Result := Null
  else
    Result := Value;
end;


end.

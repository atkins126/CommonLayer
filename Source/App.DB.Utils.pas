{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Utils;

interface

uses
  System.SysUtils, System.Variants, Data.DB;

  // IsNullPK
  function IsNullID(const Value: Variant): Boolean;
  function IsNull(const Value, ReplaceValue: Variant): Variant;
  function IfNull(const Value, NullValue: Variant): Variant;

  function GetCurrentHID(Value: Integer): string;

implementation

function IsNullID(const Value: Variant): Boolean;
begin
  Result := VarIsEmpty(Value) or VarIsNull(Value) or
            (VarToStr(Value) = '') or (VarToStr(Value) = '0');
end;

function IsNull(const Value, ReplaceValue: Variant): Variant;
begin
  if VarIsEmpty(Value) or VarIsNull(Value) then
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

function GetCurrentHID(Value: Integer): string;
const
  HID_SIZE = 4;
begin
  Result := IntToStr(Value);
  Result := StringOfChar('0', HID_SIZE - Length(Result)) + Result;
end;

end.

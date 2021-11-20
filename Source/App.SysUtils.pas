{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.SysUtils;

interface

uses
  System.SysUtils, System.Variants, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.Windows,
  Registry;

  function ReadStr(const Key, DefaultValue: string): string;
  procedure SaveStr(const Key, Value: string);

  function CodeString(const Value: string; Crypt: Boolean): string;

implementation

function ReadStr(const Key, DefaultValue: string): String;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(Key);
  try
    Result := Reg.ReadString('', '', DefaultValue);
  finally
    Reg.Free;
  end;
end;

procedure SaveStr(const Key, Value: string);
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(Key);
  try
    Reg.WriteString('', '', Value);
  finally
    Reg.Free;
  end;
end;

function CodeString(const Value: string; Crypt: Boolean): string;
const
  Pas = 10;
var
  i: Integer;
  Delta: Integer;
  Res: Integer;
begin
  Result := '';
  for i := 1 to Length(Value) do begin
    Delta := ((i xor Pas) mod (256 - 32));

    if Crypt then
      Res:= ((Ord(Value[i]) + Delta) mod (256 - 32)) + 32
    else begin
      Res := Ord(Value[i]) - Delta - 32;

      if (Res < 32) then
        Res:= Res + 256 - 32;
    end;

    Result := Result + Chr(Res);
  end;
end;

end.

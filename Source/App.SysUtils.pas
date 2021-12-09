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
  System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Registry;

type
  TRegHelper = class
  public
    class function ReadStr(const Key, DefaultValue: string): string;
    class procedure SaveStr(const Key, Value: string);
  end;

  TIOHelper = class
  public
    class function ReadStrFromFile(const FileName: string): string;
    class procedure WriteStrToFile(const FileName, Value: string);
  end;

  function CodeString(const Value: string; Crypt: Boolean): string;

implementation

{TRegHelper}

class function TRegHelper.ReadStr(const Key, DefaultValue: string): String;
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

class procedure TRegHelper.SaveStr(const Key, Value: string);
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

{ TIOHelper }

class function TIOHelper.ReadStrFromFile(const FileName: string): string;
var
  Stream: TFileStream;
  Buf: TBytes;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(Result, Stream.Size);
    Stream.Position := 0;
    SetLength(Buf, Stream.Size);
    Stream.ReadBuffer(Buf, Stream.Size);

    Result := TEncoding.Unicode.GetString(Buf);
  finally
    Stream.Free;
  end;
end;

class procedure TIOHelper.WriteStrToFile(const FileName, Value: string);
var
  Stream: TFileStream;
begin
  Stream:= TFileStream.Create(FileName, fmCreate);
  try
    Stream.WriteBuffer(Pointer(Value)^, Length(Value) * SizeOf(Char));
  finally
    Stream.Free;
  end;
end;

end.

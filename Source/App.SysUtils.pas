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

  {проверяет входной параметр валидность ID}
  function IsNullID(const Value: Variant): Boolean;

  {Если Value = Null, то возвращаем ReplaceValue}
  function IsNull(const Value, ReplaceValue: Variant): Variant;

  {Если Value = NullValue, то возвращаем Null}
  function IfNull(const Value, NullValue: Variant): Variant;

  function ReadStr(const Key, DefaultValue: string): string;
  procedure SaveStr(const Key, Value: string);

  function CodeString(const Value: string; Crypt: Boolean): string;

  function MessageDlgExt(const Text, Caption: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;

  procedure ErrorMessage(const Text: string; Args: array of const); overload;
  procedure ErrorMessage(const Text: string); overload;
  procedure Error(const Text: string);
  function Confirm(const Text: string): Boolean;
  procedure Information(const Text: string);

  procedure CenterButtons(Width: Integer; Button1, Button2: TWinControl);

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

function MessageDlgExt(const Text, Caption: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
var
  Flags: Cardinal;
begin
  case DlgType of
    mtWarning:
      Flags := MB_ICONERROR;
    mtError:
      Flags := MB_ICONERROR;
    mtInformation:
      Flags := MB_ICONINFORMATION;
    mtConfirmation:
      Flags := MB_ICONQUESTION;
    mtCustom:
      Flags := MB_USERICON;
    else
      Flags:= 0;
  end;

  if (mbYes in Buttons) or (mbOk in Buttons) then
    Flags := Flags or MB_OK;

  if (mbYes in Buttons) and (mbNo in Buttons) then
    Flags := Flags or MB_YESNO;

  if (mbOK in Buttons) and (mbCancel in Buttons) then
    Flags := Flags + MB_OKCANCEL;

  Result := Application.MessageBox(PWideChar(Text), PWideChar(Caption), Flags);
end;

procedure ErrorMessage(const Text: string; Args: array of const); overload;
begin
  MessageDlgExt(Format(Text, Args), 'ОШИБКА', mtError, [mbOK]);
end;

procedure ErrorMessage(const Text: string); overload;
begin
  MessageDlgExt(Text, 'ОШИБКА', mtError, [mbOK]);
end;

procedure Error(const Text: string);
begin
  raise Exception.Create(Text);
end;

function Confirm(const Text: string): Boolean;
var
  Msg: string;
begin
  if (Text <> '') and (Text[Length(Text)] <> '?') then
    Msg := Text + '?'
  else
    Msg := Text;

  Result := MessageDlgExt(Msg, 'ПОДТВЕРЖДЕНИЕ', mtConfirmation, [mbYes, mbNo]) = mrYes;
  Application.ProcessMessages;
end;

procedure Information(const Text: string);
begin
  MessageDlgExt(Text, 'ИНФОРМАЦИЯ', mtInformation, [mbOK]);
end;

procedure CenterButtons(Width: Integer; Button1, Button2: TWinControl);
var
  BtnWidth: Integer;
  Left: Integer;
begin
  BtnWidth := 0;
  if Button1.Visible then
    BtnWidth := BtnWidth + Button1.Width;

  if Button2.Visible then
    BtnWidth := BtnWidth + Button2.Width;

  if Button1.Visible and Button2.Visible then
    Inc(BtnWidth, 10);

  Left := (Width div 2) - (BtnWidth div 2);
  if (Left <= 0) then
    Left := 1;

  Button1.Left := Left;
  Button2.Left := Left;
  if Button1.Visible and Button2.Visible then
    Button2.Left := Left + 10 + Button1.Width + 1;
end;

end.

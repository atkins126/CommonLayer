{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.VCL.Helper;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.FileCtrl, JvZlibMultiple;

type
  TVCLHelper = class
  public
    {выбор каталога}
    class function ChooseDirectory(Owner: TWinControl; const Caption: string; var Directory: string): Boolean;

    {архивирование каталога}
    class procedure CompressDirectory(const Source, FileName: string);

    {разархивирование файла}
    class procedure DecompressFile(const FileName, Directory: string);

    class function MessageDlgExt(const Text, Caption: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
    class procedure ErrorMessage(const Text: string; Args: array of const); overload;
    class procedure ErrorMessage(const Text: string); overload;
    class function Confirm(const Text: string): Boolean;
    class procedure Information(const Text: string);

    class procedure CenterButtons(Width: Integer; Button1, Button2: TWinControl);
  end;

implementation

class function TVCLHelper.ChooseDirectory(Owner: TWinControl; const Caption: string; var Directory: string): Boolean;
var
  Msg: string;
begin
  if Caption = '' then
    Msg := 'Выберите каталог'
  else
    Msg := Caption;

  Result :=  SelectDirectory(Msg, '', Directory, [sdNewUI], Owner);
end;

class procedure TVCLHelper.CompressDirectory(const Source, FileName: string);
var
  Zlib: TJvZlibMultiple;
begin
  Zlib := TJvZlibMultiple.Create(nil);
  try
    Zlib.CompressDirectory(Source, True, FileName);
  finally
    Zlib.Free;
  end;
end;

class procedure TVCLHelper.DecompressFile(const FileName, Directory: string);
var
  Zlib: TJvZlibMultiple;
begin
  Zlib := TJvZlibMultiple.Create(nil);
  try
    Zlib.DecompressFile(FileName, Directory, True);
  finally
    Zlib.Free;
  end;
end;

class function TVCLHelper.MessageDlgExt(const Text, Caption: string;
  DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
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

class procedure TVCLHelper.ErrorMessage(const Text: string; Args: array of const);
begin
  MessageDlgExt(Format(Text, Args), 'ОШИБКА', mtError, [mbOK]);
end;

class procedure TVCLHelper.ErrorMessage(const Text: string);
begin
  MessageDlgExt(Text, 'ОШИБКА', mtError, [mbOK]);
end;

class function TVCLHelper.Confirm(const Text: string): Boolean;
var
  Msg: string;
  Len: Integer;
begin
  Len := Length(Text);
  if (Len > 0) and (Text[Len] <> '?') then
    Msg := Text + '?'
  else
    Msg := Text;

  Result := MessageDlgExt(Msg, 'ПОДТВЕРЖДЕНИЕ', mtConfirmation, [mbYes, mbNo]) = mrYes;
  Application.ProcessMessages;
end;

class procedure TVCLHelper.Information(const Text: string);
begin
  MessageDlgExt(Text, 'ИНФОРМАЦИЯ', mtInformation, [mbOK]);
end;

class procedure TVCLHelper.CenterButtons(Width: Integer; Button1, Button2: TWinControl);
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

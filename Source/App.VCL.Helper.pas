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
  Winapi.Windows, System.SysUtils, System.Variants, System.Zip, System.IOUtils,
  Generics.Collections, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.FileCtrl,
  Winapi.ActiveX, Winapi.ShellAPI;

type
  TVCLHelper = class
  public
    class function ChooseDirectory(Owner: TWinControl; const Caption: string; var Directory: string): Boolean;

    class procedure ZipDirectory(const Source, FileName: string);
    class procedure UnzipArchive(const FileName, Dest: string);

    class function MessageDlgExt(const Text, Caption: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
    class procedure ErrorMessage(const Text: string; Args: array of const); overload;
    class procedure ErrorMessage(const Text: string); overload;
    class function Confirm(const Text: string): Boolean;
    class procedure Information(const Text: string);

    class procedure CenterButtons(Width: Integer; Button1, Button2: TWinControl);

    class procedure ShellExecute(const AWnd: HWND; const AOperation, AFileName: string;
                                 const AParameters: string = ''; const ADirectory: string = '';
                                 const AShowCmd: Integer = SW_SHOWNORMAL);

    class procedure DelayedExecution(const FileName, Parameters: string);
  end;

implementation

class function TVCLHelper.ChooseDirectory(Owner: TWinControl; const Caption: string; var Directory: string): Boolean;
var
  Msg: string;
begin
  if Caption = '' then
    Msg := '¬˚·ÂËÚÂ Í‡Ú‡ÎÓ„'
  else
    Msg := Caption;

  Result :=  SelectDirectory(Msg, '', Directory, [sdNewUI], Owner);
end;

class procedure TVCLHelper.ZipDirectory(const Source, FileName: string);
var
  ZipFile: TZipFile;
  ArchiveFiles: TArray<string>;
  SourceFile: string;
  SourcePath: string;
  DestFile: string;
begin
  SourcePath := IncludeTrailingPathDelimiter(Source);

  ZipFile:= TZipFile.Create;
  try
    ZipFile.Open(FileName, zmWrite);

    ArchiveFiles := TDirectory.GetFiles(Source, '*.*', TSearchOption.soAllDirectories, nil);
    for SourceFile in ArchiveFiles do begin
      if SameText(SourcePath, ExtractFilePath(SourceFile)) then
        DestFile := ExtractFileName(SourceFile)
      else begin
        DestFile := SourceFile;
        Delete(DestFile, 1, Length(SourcePath));
      end;

      ZipFile.Add(SourceFile, DestFile, zcDeflate);
    end;

    ZipFile.Close;
  finally
    ZipFile.Free;
  end;
end;

class procedure TVCLHelper.UnzipArchive(const FileName, Dest: string);
var
  ZipFile: TZipFile;
begin
  ZipFile := TZipFile.Create;
  try
    ZipFile.Open(FileName, zmRead);
    ZipFile.ExtractAll(Dest);
    ZipFile.Close;
  finally
    ZipFile.Free;
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
  MessageDlgExt(Format(Text, Args), 'Œÿ»¡ ¿', mtError, [mbOK]);
end;

class procedure TVCLHelper.ErrorMessage(const Text: string);
begin
  MessageDlgExt(Text, 'Œÿ»¡ ¿', mtError, [mbOK]);
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

  Result := MessageDlgExt(Msg, 'œŒƒ“¬≈–∆ƒ≈Õ»≈', mtConfirmation, [mbYes, mbNo]) = mrYes;
  Application.ProcessMessages;
end;

class procedure TVCLHelper.Information(const Text: string);
begin
  MessageDlgExt(Text, '»Õ‘Œ–Ã¿÷»ﬂ', mtInformation, [mbOK]);
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

class procedure TVCLHelper.ShellExecute(const AWnd: HWND; const AOperation, AFileName,
  AParameters, ADirectory: string; const AShowCmd: Integer);
var
  ExecInfo: TShellExecuteInfo;
  NeedUnitialize: Boolean;
  ExitCode: Cardinal;
begin
  Assert(AFileName <> '');

  NeedUnitialize := Succeeded(CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE));
  try
    FillChar(ExecInfo, SizeOf(ExecInfo), 0);
    ExecInfo.cbSize := SizeOf(ExecInfo);

    ExecInfo.Wnd := AWnd;
    ExecInfo.lpVerb := Pointer(AOperation);
    ExecInfo.lpFile := PChar(AFileName);
    ExecInfo.lpParameters := Pointer(AParameters);
    ExecInfo.lpDirectory := Pointer(ADirectory);
    ExecInfo.nShow := AShowCmd;
    ExecInfo.fMask := SEE_MASK_NOASYNC { = SEE_MASK_FLAG_DDEWAIT ‰Îˇ ÒÚ‡˚ı ‚ÂÒËÈ Delphi }
                   or SEE_MASK_FLAG_NO_UI;
  {$IFDEF UNICODE}
    ExecInfo.fMask := ExecInfo.fMask or SEE_MASK_UNICODE;
  {$ENDIF}

  {$WARN SYMBOL_PLATFORM OFF}
    Win32Check(ShellExecuteEx(@ExecInfo));
  {$WARN SYMBOL_PLATFORM ON}
  finally
    TVCLHelper.Information('Finished');
    if NeedUnitialize then
      CoUninitialize;
  end;
end;

class procedure TVCLHelper.DelayedExecution(const FileName, Parameters: string);
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  WaitRes: Cardinal;
begin
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);
  StartupInfo.wShowWindow := SW_SHOW;

  CreateProcess(nil,
                PChar(FileName + ' ' + Parameters),
                nil,
                nil,
                True,
                CREATE_NEW_CONSOLE,
                nil,
                PChar(ExtractFileDir(Application.ExeName)),
                StartupInfo,
                ProcessInfo);

  repeat
    WaitRes := WaitForSingleObject(ProcessInfo.hProcess, 200);
    Application.ProcessMessages;
  until WaitRes = WAIT_OBJECT_0;
end;

end.

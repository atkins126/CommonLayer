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
  end;

implementation

class function TVCLHelper.ChooseDirectory(Owner: TWinControl; const Caption: string; var Directory: string): Boolean;
var
  s: string;
begin
  if Caption = '' then
    s := '¬ыберите каталог'
  else
    s := Caption;

  Result :=  SelectDirectory(s, '', Directory, [sdNewUI], Owner);
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

end.

{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

// Убрать этот модуль, а перенести все константы в App.Application

unit App.Constants;

interface

uses
  Vcl.Forms, System.SysUtils;

//const
//  {$I App.Constants.inc}

var
  AppPath: string = '';
  AppName: string = '';
  AppVersion: string = '1.01';
//  AppMajorVersion: string = '1';
//  AppMinorVersion: string = '01';

  function GetApplicationRootKey(): string;

implementation

function GetApplicationRootKey(): string;
begin
  Result := '\Software';
  if AppName <> '' then
    Result := Result + '\' + AppName;
end;

initialization
  AppPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  Delete(AppPath, Length(AppPath), 1);

end.

unit App.Constants;

interface

uses
  Vcl.Forms, System.SysUtils;

var
  AppPath: string = '';
  AppName: string = '';
  AppVersion: string = '1.01';
  AppMajorVersion: string = '1';
  AppMinorVersion: string = '01';

implementation


initialization
  AppPath := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  Delete(AppPath, Length(AppPath), 1);

end.

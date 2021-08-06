unit DBOptionsTest;

interface

uses
  Winapi.Windows, TestFramework, System.SysUtils, App.Options, System.Variants,
  App.DB.Options, TD.DBOptions, App.Params, IniFiles, System.Classes, Vcl.Forms,
  Math, TD.Constants, Registry;

type
  TestTDBOptions = class(TTestCase)
  strict private
    FDBOptions: TDBOptions;
  protected
    function GetConfigFileName(): string;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestLoadDBParamsFromIniFile;
    procedure TestLoadAdditionalParamsFromIniFile;
    procedure TestSaveToIniFile;
    procedure TestBoolean;

    procedure TestSaveToRegistry;
  end;

implementation

function TestTDBOptions.GetConfigFileName: string;
const
  ConfigFileName: string = 'Config.ini';
//var
//  Path: string;
begin
//  Path := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
//  Delete(Path, Length(Path), 1);

  Result := 'd:\Projects\Delphi\CommonLayer\Tests\TestData' + '\' + ConfigFileName;
end;

procedure TestTDBOptions.SetUp;
begin
  FDBOptions := TDBOptions.Create(nil);
end;

procedure TestTDBOptions.TearDown;
begin
  FDBOptions.Free;
  FDBOptions := nil;
end;

procedure TestTDBOptions.TestLoadDBParamsFromIniFile;
var
  IniFile: TIniFile;
begin
   if not FileExists(GetConfigFileName)  then
    raise Exception.Create('Файл "' + GetConfigFileName + '" не найден');

  IniFile := TIniFile.Create(GetConfigFileName);
  try
    FDBOptions.Load(IniFile);

    CheckEquals(CompareText(FDBOptions.Server, DBServer), 0);
    CheckEquals(FDBOptions.Port, DBPort);
    CheckEquals(CompareText(FDBOptions.Database, DBDatabase), 0);
    CheckEquals(CompareText(FDBOptions.UserName, DBLogin), 0);
    CheckEquals(CompareText(FDBOptions.Password, DBPassword), 0);
  finally
    IniFile.Free;
  end;
end;

procedure TestTDBOptions.TestBoolean;
var
  i: Integer;
  Res: TStrings;
  CardNum, Name: string;
begin
  i := Integer(True);
  i := Integer(False);

  Res := TStringList.Create;
  try
    Res.Values['99999']:= 'John';
    CardNum := Res.Names[0];
    Name := Res.ValueFromIndex[0];
  finally
    Res.Free;
  end;
end;

procedure TestTDBOptions.TestLoadAdditionalParamsFromIniFile;
const
  BooleanParam: Boolean = True;
  IntegerParam: Integer = 999;
  StringParam: string = 'Test тест';
  DoubleParam: Double = 10101.9909;
  DateTimeParam: string = '27.01.1984 10:15:59';
var
  IniFile: TIniFile;
begin
   if not FileExists(GetConfigFileName)  then
    raise Exception.Create('Файл "' + GetConfigFileName + '" не найден');

  IniFile := TIniFile.Create(GetConfigFileName);
  try
    FDBOptions.Load(IniFile);

    CheckEquals(FDBOptions.BooleanParam, BooleanParam);
    CheckEquals(FDBOptions.IntegerParam, IntegerParam);
    CheckEquals(CompareText(FDBOptions.StringParam, StringParam), 0);
    CheckEquals(RoundTo(FDBOptions.DoubleParam, -4), RoundTo(DoubleParam, -4));
    CheckEquals(FDBOptions.DateTimeParam, StrToDateTime(DateTimeParam));
  finally
    IniFile.Free;
  end;
end;

procedure TestTDBOptions.TestSaveToIniFile;
var
  IniFile: TIniFile;
begin
  // TODO: Setup method call parameters
  FDBOptions.Save(IniFile);
  // TODO: Validate method results
end;

procedure TestTDBOptions.TestSaveToRegistry;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;

//    FDBOptions.Save(Reg);
  finally
    Reg.Free;
  end;
end;

initialization
  RegisterTest(TestTDBOptions.Suite);
end.


program CommonLayerTest;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  App.Application in '..\Source\App.Application.pas',
  App.DB.Application in '..\Source\App.DB.Application.pas',
  App.DB.Connection in '..\Source\App.DB.Connection.pas',
  App.DB.Options in '..\Source\App.DB.Options.pas',
  App.FB.Connection in '..\Source\App.FB.Connection.pas',
  App.Options in '..\Source\App.Options.pas',
  App.Params in '..\Source\App.Params.pas',
  TD.DBOptions in 'TestData\TD.DBOptions.pas',
  DBOptionsTest in 'DBOptionsTest.pas',
  TD.FBConnection in 'TestData\TD.FBConnection.pas',
  FBConnectionTest in 'FBConnectionTest.pas',
  TD.Constants in 'TestData\TD.Constants.pas',
  TD.DBApplication in 'TestData\TD.DBApplication.pas',
  App.DB.DAO in '..\Source\App.DB.DAO.pas',
  App.DB.Entity in '..\Source\App.DB.Entity.pas',
  App.DB.MetaData in '..\Source\App.DB.MetaData.pas',
  App.DB.Columns in '..\Source\App.DB.Columns.pas',
  App.SysUtils in '..\Source\App.SysUtils.pas',
  App.DB.Service in '..\Source\App.DB.Service.pas',
  App.Constants in '..\Source\App.Constants.pas',
  App.SQLite.Connection in '..\Source\App.SQLite.Connection.pas',
  App.MSSQL.Connection in '..\Source\App.MSSQL.Connection.pas',
  App.DB.Types in '..\Source\App.DB.Types.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;
end.


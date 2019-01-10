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
  App.DBApplication in '..\Source\App.DBApplication.pas',
  App.DBConnection in '..\Source\App.DBConnection.pas',
  App.DBOptions in '..\Source\App.DBOptions.pas',
  App.FBConnection in '..\Source\App.FBConnection.pas',
  App.Options in '..\Source\App.Options.pas',
  App.Params in '..\Source\App.Params.pas',
  TD.DBOptions in 'TestData\TD.DBOptions.pas',
  DBOptionsTest in 'DBOptionsTest.pas',
  TD.FBConnection in 'TestData\TD.FBConnection.pas',
  FBConnectionTest in 'FBConnectionTest.pas',
  TD.Constants in 'TestData\TD.Constants.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;

  DUnitTestRunner.RunRegisteredTests;
end.


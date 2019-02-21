unit FBConnectionTest;

interface

uses
  TestFramework, System.SysUtils, App.FB.Connection, System.Variants,
  FireDAC.Phys.IBBase, FireDAC.Phys.FB, IBX.IBServices, App.DB.Connection,
  TD.FBConnection, FireDAC.Phys.IBWrapper, System.Classes, FireDAC.Comp.Client,
  TD.Constants;

type
  TestTFBConnection = class(TTestCase)
  strict private
    FConnection: TFBConnection;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConnect;
    procedure TestSimpleConnect;
    procedure TestDisconnect;
  end;

implementation

procedure TestTFBConnection.SetUp;
begin
  FConnection := TFBConnection.Create(nil);
end;

procedure TestTFBConnection.TearDown;
begin
  FConnection.Free;
  FConnection := nil;
end;

procedure TestTFBConnection.TestConnect;
begin
  FConnection.Connect(DBServer, DBDatabase, DBLogin, DBPassword);
  CheckTrue(FConnection.Connected);
  CheckTrue(FConnection.ConnectionStatus = cnConnect);
end;

procedure TestTFBConnection.TestSimpleConnect;
begin
  FConnection.Server := DBServer;
  FConnection.Database := DBDatabase;
  FConnection.UserName := DBLogin;
  FConnection.Password := DBPassword;

  FConnection.Connect;
  CheckTrue(FConnection.Connected);
  CheckTrue(FConnection.ConnectionStatus = cnConnect);
end;

procedure TestTFBConnection.TestDisconnect;
begin
  FConnection.Connect(DBServer, DBDatabase, DBLogin, DBPassword);
  CheckTrue(FConnection.Connected);
  CheckTrue(FConnection.ConnectionStatus = cnConnect);

  FConnection.Disconnect;
  CheckFalse(FConnection.Connected);
  CheckTrue(FConnection.ConnectionStatus = cnDisconnect);
end;

initialization
  RegisterTest(TestTFBConnection.Suite);

end.


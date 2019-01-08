{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.FBConnection;

interface

uses
  System.Classes, System.SysUtils, System.Variants,App.DBConnection,
  FireDAC.Comp.Client, IBX.IBServices, FireDAC.Phys.IBWrapper, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB;

type
  TCLFBConnection = class(TCLDBConnection)
  private
    FFBDriverLink: TFDPhysFBDriverLink;
  protected
    procedure DoConnect(const Connection: TFDConnection); override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure BackupDataBase(const FileName: String); override;
    procedure RestoreDataBase(const FileName: String); override;
  end;

implementation

{ TCLFBConnection }

constructor TCLFBConnection.Create(Owner: TComponent);
begin
  inherited;

  FFBDriverLink := TFDPhysFBDriverLink.Create(Self);
end;

destructor TCLFBConnection.Destroy;
begin
  FFBDriverLink.Free;

  inherited;
end;

procedure TCLFBConnection.DoConnect(const Connection: TFDConnection);
const
  DB_CHARACTER_SET = 'UTF8';
var
  Server: string;
  Database: string;
  UserName: string;
  Password: string;
begin
  Server := Self.Server;
  Database := Self.Database;
  UserName := Self.UserName;
  Password := Self.Password;

  FConnectionStatus := cnNone;
  Connection.Close;
  Connection.DriverName:= 'FB';
  Connection.Params.Clear;
  Connection.Params.Add('DriverID=FB');
  Self.Server := Server;
  Self.Database := Database;
  Self.UserName := UserName;
  Self.Password := Password;
  Connection.Params.Add('SQLDialect=3');
  Connection.Params.Add('Protocol=TCPIP');
  Connection.Params.Add('CharacterSet=' + DB_CHARACTER_SET);
  Connection.Params.Add('PageSize=16384');
  Connection.Params.Add('CreateDatabase=No');
  Connection.Open();
end;

procedure TCLFBConnection.BackupDataBase(const FileName: String);
var
  BackupService: TFDIBBackup;
begin
  BackupService := TFDIBBackup.Create(Self);
  try
    BackupService.DriverLink := FFBDriverLink;
    BackupService.UserName := UserName;
    BackupService.Password := Password;
    BackupService.Host := Server;
    BackupService.Protocol := ipTCPIP;
    BackupService.Database := DataBase;
    BackupService.BackupFiles.Add(FileName);
//    BackupService.BeforeExecute := DoBeforeExecure;
//    BackupService.AfterExecute := DoAfterExecure;
    BackupService.Backup;
  finally
    BackupService.Free;
  end;
end;

procedure TCLFBConnection.RestoreDataBase(const FileName: String);
var
  RestoreService: TFDIBRestore;
begin
  FConnection.Close;

  RestoreService := TFDIBRestore.Create(Self);
  try
    RestoreService.DriverLink := FFBDriverLink;
    RestoreService.UserName := UserName;
    RestoreService.Password := Password;
    RestoreService.Host := Server;
    RestoreService.Protocol := ipTCPIP;
    RestoreService.Database := DataBase;
    RestoreService.BackupFiles.Add(FileName);
//    RestoreService.BeforeExecute := DoBeforeExecure;
//    RestoreService.AfterExecute := DoAfterExecure;
    RestoreService.Options := RestoreService.Options + [roReplace];
    RestoreService.Restore;
  finally
    RestoreService.Free;
  end;
end;

end.

{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.FB.Connection;

interface

uses
  System.Classes, System.SysUtils, System.Variants, App.DB.Connection,
  {$IFDEF UNIDAC}InterBaseUniProvider,{$ENDIF}
  {$IFDEF FIREDAC}FireDAC.Phys.FB,{$ENDIF}
  {$I DB_Links.inc};

type
  TCLFBConnection = class(TCLDBConnection)
  private
  {$IFDEF FIREDAC}
    FFBDriverLink: TFDPhysFBDriverLink;
  {$ENDIF}
    FCharset: string;
    FClientLibrary: string;
    FUseUnicode: Boolean;
  protected
    procedure DoConnect(const Connection: TDBConnection); override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure BackupDataBase(const FileName: String); override;
    procedure RestoreDataBase(const FileName: String); override;

    property Charset: string read FCharset write FCharset;
    property ClientLibrary: string read FClientLibrary write FClientLibrary;
    property UseUnicode: Boolean read FUseUnicode write FUseUnicode;
  end;

implementation

{ TCLFBConnection }

constructor TCLFBConnection.Create(Owner: TComponent);
begin
  inherited;

  FCharset := 'UTF8';
  FClientLibrary := 'fbclient.dll';
  FUseUnicode := True;

{$IFDEF FIREDAC}
  FFBDriverLink := TFDPhysFBDriverLink.Create(Self);
  FFBDriverLink.DriverID := 'FB';
  FFBDriverLink.VendorLib := ClientLibrary;
{$ENDIF}
end;

destructor TCLFBConnection.Destroy;
begin
{$IFDEF FIREDAC}
  FFBDriverLink.Free;
{$ENDIF}

  inherited;
end;

procedure TCLFBConnection.DoConnect(const Connection: TDBConnection);
var
  Server: string;
  UserName: string;
  Password: string;
  Database: string;
  Port: Integer;
begin
  FConnectionStatus := cnNone;
  Connection.Close;

  Server := Self.Server;
  UserName := Self.UserName;
  Password := Self.Password;
  Database := Self.Database;
  Port := Self.Port;;

{$IFDEF FIREDAC}
  Connection.DriverName:= 'FB';
  Connection.Params.Clear;
  Connection.Params.Add('DriverID=FB');
  Connection.Params.Add('SQLDialect=3');
  Connection.Params.Add('Protocol=TCPIP');
  Connection.Params.Add('CharacterSet=' + FCharset);
  Connection.Params.Add('PageSize=16384');
  Connection.Params.Add('CreateDatabase=No');
  if Port > 0 then
    Connection.Params.Add('Server=' + Server + ',' + IntToStr(Port))
  else
    Connection.Params.Add(Server);

  Connection.Params.Add('Database=' + Database);
  Connection.Params.Values['User_Name'] := UserName;
  Connection.Params.Values['Password'] := Password;
  Connection.LoginPrompt := False;
{$ENDIF}

{$IFDEF UNIDAC}
  Connection.ProviderName := 'InterBase';
  Connection.SpecificOptions.Values['Charset'] := FCharset;
  Connection.SpecificOptions.Values['ClientLibrary'] := ClientLibrary;
  Connection.SpecificOptions.Values['UseUnicode'] := BoolToStr(FUseUnicode, True);
  Connection.LoginPrompt := False;
{$ENDIF}

  Connection.Connected := True;
end;

procedure TCLFBConnection.BackupDataBase(const FileName: String);
//var
//  BackupService: TFDIBBackup;
begin
//  BackupService := TFDIBBackup.Create(Self);
//  try
//    BackupService.DriverLink := FFBDriverLink;
//    BackupService.UserName := UserName;
//    BackupService.Password := Password;
//    BackupService.Host := Server;
//    BackupService.Protocol := ipTCPIP;
//    BackupService.Database := DataBase;
//    BackupService.BackupFiles.Add(FileName);
////    BackupService.BeforeExecute := DoBeforeExecure;
////    BackupService.AfterExecute := DoAfterExecure;
//    BackupService.Backup;
//  finally
//    BackupService.Free;
//  end;
end;

procedure TCLFBConnection.RestoreDataBase(const FileName: String);
//var
//  RestoreService: TFDIBRestore;
begin
//  FConnection.Close;
//
//  RestoreService := TFDIBRestore.Create(Self);
//  try
//    RestoreService.DriverLink := FFBDriverLink;
//    RestoreService.UserName := UserName;
//    RestoreService.Password := Password;
//    RestoreService.Host := Server;
//    RestoreService.Protocol := ipTCPIP;
//    RestoreService.Database := DataBase;
//    RestoreService.BackupFiles.Add(FileName);
////    RestoreService.BeforeExecute := DoBeforeExecure;
////    RestoreService.AfterExecute := DoAfterExecure;
//    RestoreService.Options := RestoreService.Options + [roReplace];
//    RestoreService.Restore;
//  finally
//    RestoreService.Free;
//  end;
end;

end.

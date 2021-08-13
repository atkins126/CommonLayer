{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Application;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Vcl.Forms,
  App.Application, App.Options, App.DB.Options, App.DB.Connection;

type
  TCLDBApplication = class(TCLApplication)
  private
    procedure ConnectionStatusChanged(Sender: TObject; const Status: TCLConnectionStatus);
    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
  protected
    FDBConnection: TCLDBConnection;

    function OptionsClass: TCLOptionsClass; override;
    function DBConnectionClass: TCLDBConnectionClass; virtual; abstract;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure LoadSettingsFromDB; virtual;

    property Connected: Boolean read GetConnected write SetConnected;
  end;

implementation

{ TCLDBApplication }

constructor TCLDBApplication.Create(Owner: TComponent);
begin
  inherited;

  FDBConnection := DBConnectionClass.Create(Self);
  FDBConnection.OnConnectionStatusChange := ConnectionStatusChanged;
end;

destructor TCLDBApplication.Destroy;
begin

  inherited;
end;

procedure TCLDBApplication.ConnectionStatusChanged(Sender: TObject;
  const Status: TCLConnectionStatus);
begin
  if Status = cnConnect then
    LoadSettingsFromDB;
end;

function TCLDBApplication.GetConnected: Boolean;
begin
  Result := FDBConnection.Connected;
end;

procedure TCLDBApplication.SetConnected(const Value: Boolean);
begin
  FDBConnection.Connected := Value;
end;

procedure TCLDBApplication.LoadSettingsFromDB;
begin
  TCLDBOptions(FOptions).LoadSettingsFromDB;
end;

function TCLDBApplication.OptionsClass: TCLOptionsClass;
begin
  Result := TCLDBOptions;
end;

end.

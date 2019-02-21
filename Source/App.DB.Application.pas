{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Application;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Vcl.Forms, IniFiles,
  App.Application,  App.Options, App.DB.Options, App.DB.Connection;

type
  TCLDBApplication = class(TCLApplication)
  private
  protected
    FDBConnection: TCLDBConnection;

    function OptionsClass(): TCLOptionsClass; override;
    function DBConnectionClass(): TCLDBConnectionClass; virtual; abstract;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure LoadSettingsFromDB(); virtual;
  end;

implementation

{ TCLDBApplication }

constructor TCLDBApplication.Create(Owner: TComponent);
begin
  inherited;

  FDBConnection := DBConnectionClass.Create(Self);

//  {создание слоя сервисов}
//  CreateServiceLayer();
end;

destructor TCLDBApplication.Destroy;
begin

  inherited;
end;

procedure TCLDBApplication.LoadSettingsFromDB;
begin
  TCLDBOptions(FOptions).LoadSettingsFromDB();
end;

function TCLDBApplication.OptionsClass: TCLOptionsClass;
begin
  Result := TCLDBOptions;
end;

end.

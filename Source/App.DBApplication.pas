{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DBApplication;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Vcl.Forms, IniFiles,
  App.Application,  App.Options, App.DBOptions, App.DBConnection;

type
  TCLDBApplication = class(TCLApplication)
  private
    FDBConnection: TCLDBConnection;
  protected
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
  TCLDBOptions(Options).LoadSettingsFromDB();
end;

function TCLDBApplication.OptionsClass: TCLOptionsClass;
begin
  Result := TCLDBOptions;
end;

end.

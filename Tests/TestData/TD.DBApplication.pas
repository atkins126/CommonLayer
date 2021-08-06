unit TD.DBApplication;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Vcl.Forms, IniFiles,
  App.Application,  App.Options, App.DB.Options, App.DB.Connection,
  App.DB.Application, TD.DBOptions, App.Params, TD.FBConnection;

type
  TDBApplication = class(TCLDBApplication)
  private
  protected
    function OptionsClass(): TCLOptionsClass; override;
    function DBConnectionClass(): TCLDBConnectionClass; override;
    function GetApplicationName(): string; override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;
  end;

implementation

{ TDBApplication }

constructor TDBApplication.Create(Owner: TComponent);
begin
  inherited;

end;

destructor TDBApplication.Destroy;
begin

  inherited;
end;

function TDBApplication.OptionsClass: TCLOptionsClass;
begin
  Result := TDBOptions;
end;

function TDBApplication.DBConnectionClass: TCLDBConnectionClass;
begin
  Result := TFBConnection;
end;

function TDBApplication.GetApplicationName: string;
begin
  Result := 'CommonLayerTest';
end;

end.

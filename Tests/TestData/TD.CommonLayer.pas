unit TD.CommonLayer;

interface

uses
  Vcl.Forms, System.SysUtils, App.Application, App.Options, TD.DBApplication,
  App.Container;

type
  TCommonLayer = class(TAppContainer)
  private
    class function GetApplication(): TDBApplication; static;

  protected
    class function ApplicationClass(): TCLApplicationClass; override;
  public
    class property Application: TDBApplication read GetApplication;
//    class property Options: TCLOptions read GetOptions;

  end;

implementation

{ TAppContainer }

class function TCommonLayer.ApplicationClass: TCLApplicationClass;
begin
  Result := TDBApplication;
end;

class function TCommonLayer.GetApplication: TDBApplication;
begin
  Result := TDBApplication(FApplication);
end;

//initialization
//  TCommonLayer.Init;
//
//finalization
//  TCommonLayer.Done;

end.

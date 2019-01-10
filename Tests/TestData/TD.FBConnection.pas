unit TD.FBConnection;

interface

uses
  System.Classes, System.SysUtils, System.Variants,App.DBConnection,
  FireDAC.Comp.Client, IBX.IBServices, FireDAC.Phys.IBWrapper, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, App.FBConnection;

type
  TFBConnection = class(TCLFBConnection)
  private
  protected
    procedure DoConnect(const Connection: TFDConnection); override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;
  end;

implementation

{ TFBConnection }

constructor TFBConnection.Create(Owner: TComponent);
begin
  inherited;

end;

destructor TFBConnection.Destroy;
begin

  inherited;
end;

procedure TFBConnection.DoConnect(const Connection: TFDConnection);
begin
  inherited;

end;

end.

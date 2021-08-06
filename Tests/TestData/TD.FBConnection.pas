unit TD.FBConnection;

interface

uses
  System.Classes, System.SysUtils, System.Variants, App.DB.Connection,
  Uni, App.FB.Connection,
  {$I DB_Links.inc};

type
  TFBConnection = class(TCLFBConnection)
  private
  protected
    procedure DoConnect(const Connection: TDBConnection); override;
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

procedure TFBConnection.DoConnect(const Connection: TDBConnection);
begin
  inherited;

end;

end.

unit App.Del.Form.Presenter;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms,
  App.Dialog.Presenter;

type
  TDelFormPresenter<T> = class(TDialogPresenter)
  private
    FInstance: T;
  protected
    procedure SetInstance(const Value: T); virtual;
    procedure InternalDelete; virtual; abstract;
    function GetDelMessage: string; abstract;
  public
    constructor Create(Dialog: IMessageDialog; Instance: T); overload; virtual;

    function Delete: Boolean;

    property Instance: T read FInstance write SetInstance;
  end;

implementation

{ TDelFormPresenter<T> }

constructor TDelFormPresenter<T>.Create(Dialog: IMessageDialog; Instance: T);
begin
  inherited Create(Dialog);

  Self.Instance := Instance;
end;

procedure TDelFormPresenter<T>.SetInstance(const Value: T);
begin
  FInstance := Value;
end;

function TDelFormPresenter<T>.Delete: Boolean;
var
  ErrorText: string;
begin
  IMessageDialog(FEditDialog).SetMessage(GetDelMessage);
  Result := FEditDialog.ShowModal = mrOK;
  if not Result then begin
//    Cancel;
    Exit;
  end;

//  if not Validate(ErrorText) then
//  begin
//    if Assigned(OnError) then
//      OnError(ErrorText);
//
//    FEditDialog.SetModalResult(mrNone);
//    Exit;
//  end;

  InternalDelete;
end;

end.

{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Edit.Form.Presenter;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Controls,
  App.Dialog.Presenter, eduDialog;

type
  TEditFormPresenter<T> = class(TDialogPresenter)
  private
    FInstance: T;
  protected
    procedure SetInstance(const Value: T); virtual;
    procedure PostValues; virtual; abstract;
    procedure OKAction; virtual; abstract;
    procedure Cancel; virtual; abstract;
    function Validate(var vMessage: string): Boolean; override;
  public
    constructor Create(Owner: TComponent; Instance: T); overload; virtual;

    function Edit: Boolean;

    property Instance: T read FInstance write SetInstance;
  end;

implementation

{ TEditFormPresenter<T> }

constructor TEditFormPresenter<T>.Create(Owner: TComponent; Instance: T);
begin
  inherited Create(Owner);

  Self.Instance := Instance;
end;

procedure TEditFormPresenter<T>.SetInstance(const Value: T);
begin
  FInstance := Value;
end;

function TEditFormPresenter<T>.Validate(var vMessage: string): Boolean;
begin
{$IFDEF ASProtect}
  {$I include\aspr_crypt_begin1.inc}
  if not Result then
  begin
    Result := True;
    vMessage := '';
  end;
  {$I include\aspr_crypt_end1.inc}

  {$I include\aspr_crypt_begin5.inc}
  if not Result then
  begin
    Result := True;
    vMessage := '';
  end;
  {$I include\aspr_crypt_end5.inc}

  {$I include\aspr_crypt_begin15.inc}
  if Result then
  begin
    Result := False;
    vMessage := '';
  end;
  {$I include\aspr_crypt_end15.inc}
{$ELSE}
  Result := True;
  vMessage := '';
{$ENDIF}
end;

function TEditFormPresenter<T>.Edit: Boolean;
var
  ErrorText: string;
begin
  Result := FEditDialog.ShowModal = mrOK;
  if not Result then begin
    Cancel;
    Exit;
  end;

  if not Validate(ErrorText) then
  begin
    FEditDialog.ShowErrorMessage(ErrorText);
    FEditDialog.ModalResult := mrNone;
    Exit;
  end;

  PostValues;
  OKAction;
end;


end.

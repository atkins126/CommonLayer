{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Edit.Form.Presenter;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms,
  App.Dialog.Presenter;

type
  IEditDialog<T> = interface(ICLDialog)
    ['{A43EA8B9-D6B5-45D8-80DE-AD077FC48E2A}']

    procedure SetInstance(const Value: T);
    procedure PostValues(const Value: T);
  end;

  TEditFormPresenter<T> = class(TDialogPresenter)
  private
    FInstance: T;
  protected
    procedure SetInstance(const Value: T); virtual;
    procedure PostValues; virtual;
    procedure InternalSave; virtual; abstract;
    procedure Cancel; virtual; abstract;
    function Validate(var vMessage: string): Boolean; virtual;
  public
    constructor Create(Dialog: IEditDialog<T>; Instance: T); overload; virtual;

    function Edit: Boolean;

    property Instance: T read FInstance write SetInstance;
  end;

implementation

{ TEditFormPresenter<T> }

constructor TEditFormPresenter<T>.Create(Dialog: IEditDialog<T>; Instance: T);
begin
  inherited Create(Dialog);

  Self.Instance := Instance;
end;

procedure TEditFormPresenter<T>.SetInstance(const Value: T);
begin
  FInstance := Value;
  IEditDialog<T>(FEditDialog).SetInstance(Value);
end;

procedure TEditFormPresenter<T>.PostValues;
begin
  IEditDialog<T>(FEditDialog).PostValues(FInstance);
end;

function TEditFormPresenter<T>.Validate(var vMessage: string): Boolean;
begin
{$IFDEF ASProtect}
  {$I include\aspr_crypt_begin1.inc}
  if not Result then begin
    Result := True;
    vMessage := '';
  end;
  {$I include\aspr_crypt_end1.inc}

  {$I include\aspr_crypt_begin5.inc}
  if not Result then begin
    Result := True;
    vMessage := '';
  end;
  {$I include\aspr_crypt_end5.inc}

  {$I include\aspr_crypt_begin15.inc}
  if Result then begin
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
  Result := ShowModal;
  if not Result then begin
    Cancel;
    Exit;
  end;

  if not Validate(ErrorText) then
  begin
    if Assigned(OnError) then
      OnError(ErrorText);

    FEditDialog.SetModalResult(mrNone);
    Exit;
  end;

  PostValues;
  InternalSave;
end;

end.

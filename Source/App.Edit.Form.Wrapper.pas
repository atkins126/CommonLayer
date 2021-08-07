{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Edit.Form.Wrapper;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Controls,
  eduDialog;

type
  TEditFormWrapper<T> = class
  private
    FInstance: T;
  protected
    FEditDialog: TedDialog;

    function DialogClass(): TDialogClass; virtual; abstract;
    procedure SetInstance(const Value: T); virtual;
    procedure PostValues; virtual; abstract;
    procedure OKAction; virtual; abstract;
    procedure Cancel; virtual; abstract;
    function Validate(var vMessage: string): Boolean; virtual;
  public
    constructor Create(Owner: TComponent); overload; virtual;
    constructor Create(Owner: TComponent; Instance: T); overload; virtual;
    destructor Destroy; override;

    function Edit: Boolean;

    property Instance: T read FInstance write SetInstance;
  end;

implementation

{ TEditFormWrapper<T> }

constructor TEditFormWrapper<T>.Create(Owner: TComponent);
begin
  inherited Create;

  FEditDialog := DialogClass.Create(Owner);
end;

constructor TEditFormWrapper<T>.Create(Owner: TComponent; Instance: T);
begin
  Create(Owner);

  Self.Instance := Instance;
end;

destructor TEditFormWrapper<T>.Destroy;
begin
  FEditDialog.Free;

  inherited;
end;

procedure TEditFormWrapper<T>.SetInstance(const Value: T);
begin
  FInstance := Value;
end;

function TEditFormWrapper<T>.Validate(var vMessage: string): Boolean;
begin
  Result := True;
end;

function TEditFormWrapper<T>.Edit: Boolean;
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

  {запись отредактированных значений}
  PostValues;
  OKAction;
end;


end.

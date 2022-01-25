{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Dialog.Presenter;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Controls,
  eduDialog;

type
  TDialogPresenter = class
  private
  protected
    FEditDialog: TedDialog;

    function GetDialogClass: TDialogClass; virtual; abstract;
    function Validate(var vMessage: string): Boolean; virtual;
  public
    constructor Create(Owner: TComponent); overload; virtual;
    destructor Destroy; override;

    function Show: Boolean;
  end;

implementation

{ TDialogPresenter }

constructor TDialogPresenter.Create(Owner: TComponent);
begin
  inherited Create;

  FEditDialog := GetDialogClass.Create(Owner);
end;

destructor TDialogPresenter.Destroy;
begin
  FEditDialog.Free;

  inherited;
end;

function TDialogPresenter.Validate(var vMessage: string): Boolean;
begin
  Result := True;
  vMessage := '';
end;

function TDialogPresenter.Show: Boolean;
begin
  Result := FEditDialog.ShowModal = mrOK;
end;

end.

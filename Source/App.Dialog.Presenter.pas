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
  System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms;

type
  TErrorEvent = procedure(const ErrorMessage: string) of object;

  ICLDialog = interface
    ['{B30340EB-A734-4F19-B6A8-92FC41ADA6BE}']
    function ShowModal: Integer;
    function GetModalResult: TModalResult;
    procedure SetModalResult(Value: TModalResult);
  end;

  IMessageDialog = interface(ICLDialog)
    ['{2D95DD13-24C6-4F55-8D6C-AB1352B4F751}']

    procedure SetMessage(const Value: string);
  end;

  TDialogPresenter = class
  private
    FOnError: TErrorEvent;
  protected
    FEditDialog: ICLDialog;
  public
    constructor Create(Dialog: ICLDialog); virtual;
    destructor Destroy; override;

    function ShowModal: Boolean;

    property OnError: TErrorEvent read FOnError write FOnError;
  end;

implementation

{ TDialogPresenter }

constructor TDialogPresenter.Create(Dialog: ICLDialog);
begin
  inherited Create;

  FEditDialog := Dialog;
end;

destructor TDialogPresenter.Destroy;
begin
  FEditDialog := nil;

  inherited;
end;

function TDialogPresenter.ShowModal: Boolean;
begin
  Result := FEditDialog.ShowModal = mrOK;
end;

end.

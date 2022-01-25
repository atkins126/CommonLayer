{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Options;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Variants,
  {$IFDEF REG_STORAGE}System.Win.Registry{$ELSE}System.IniFiles{$ENDIF},
  App.Params;

type
  TCLOptionsClass = class of TCLOptions;

  TCLOptions = class(TComponent)
  private
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure Load(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF}); virtual;
    procedure Save(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF}); virtual;
  end;

implementation

{ TCLOptions }

constructor TCLOptions.Create(Owner: TComponent);
begin
  inherited;

end;

destructor TCLOptions.Destroy;
begin

  inherited;
end;

procedure TCLOptions.Load(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF});
begin

end;

procedure TCLOptions.Save(const Context: {$IFDEF REG_STORAGE}TRegistry{$ELSE}TIniFile{$ENDIF});
begin

end;

end.

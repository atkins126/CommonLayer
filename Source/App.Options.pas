{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Options;

interface

uses
  System.Classes, System.SysUtils, System.Variants, IniFiles;

type
  TCLOptionsClass = class of TCLOptions;

  TCLOptions = class(TComponent)
  private
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    procedure LoadFromIniFile(const IniFile: TIniFile); virtual;
    procedure SaveToIniFile(const IniFile: TIniFile); virtual;

    procedure LoadFromRegistry(); virtual;
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

procedure TCLOptions.LoadFromIniFile(const IniFile: TIniFile);
begin

end;

procedure TCLOptions.SaveToIniFile(const IniFile: TIniFile);
begin

end;

procedure TCLOptions.LoadFromRegistry;
begin

end;

end.

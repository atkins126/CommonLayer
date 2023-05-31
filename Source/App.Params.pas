{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Params;

interface

uses
  Winapi.Windows, Vcl.Forms, System.SysUtils, System.Variants, System.Classes,
  Registry, IniFiles;

type
  TCLParam<T,C> = class(TPersistent)
  private
    FValue: T;
    FEmptyValue: T;
    FKeyName: string;
    FKeyPath: string;
  protected
    function GetValue(): T;
    procedure SetValue(const Value: T);

    function DefaultEmptyValue(): T; virtual; abstract;
    function ReadValue(const Context: C): T; virtual; abstract;
    procedure SaveValue(const Context: C; const Value: T); virtual; abstract;
  public
    constructor Create; overload; virtual;
    constructor Create(const KeyName, KeyPath: string; const EmptyValue: T); overload;
    constructor Create(const KeyName, KeyPath: string); overload;
    destructor Destroy; override;

    function Load(const Context: C): T; virtual; abstract;
    procedure Save(const Context: C; const Value: T); overload; virtual; abstract;
    procedure Save(const Context: C); overload; virtual; abstract;

    property KeyName: string read FKeyName write FKeyName;
    property KeyPath: string read FKeyPath write FKeyPath;
    property Value: T read GetValue write SetValue;
  end;

  TRegParam<T> = class(TCLParam<T, TRegistry>)
  private
    class var
      FRegistry: TRegistry;
      FRefCount: Integer;
  private
    function GetRegistryPath(): string;
  public
    constructor Create; override;
    destructor Destroy; override;

    function Load(const Context: TRegistry): T; overload; override;
    function Load: T; overload;
    procedure Save(const Context: TRegistry; const Value: T); overload; override;
    procedure Save(const Context: TRegistry); overload; override;
    procedure Save(const Value: T); overload;
    procedure Save; overload;
  end;

  TIniParam<T> = class(TCLParam<T, TIniFile>)
  private
  public
    function Load(const Context: TIniFile): T; override;
    procedure Save(const Context: TIniFile; const Value: T); overload; override;
    procedure Save(const Context: TIniFile); overload; override;
  end;

  TRegBooleanParam = class(TRegParam<Boolean>)
  protected
    function DefaultEmptyValue(): Boolean; override;
    function ReadValue(const Context: TRegistry): Boolean; override;
    procedure SaveValue(const Context: TRegistry; const Value: Boolean); override;
  end;

  TIniBooleanParam = class(TIniParam<Boolean>)
  protected
    function DefaultEmptyValue(): Boolean; override;
    function ReadValue(const Context: TIniFile): Boolean; override;
    procedure SaveValue(const Context: TIniFile; const Value: Boolean); override;
  end;

  TRegStringParam = class(TRegParam<string>)
  protected
    function DefaultEmptyValue(): string; override;
    function ReadValue(const Context: TRegistry): string; override;
    procedure SaveValue(const Context: TRegistry; const Value: string); override;
  end;

  TIniStringParam = class(TIniParam<string>)
  protected
    function DefaultEmptyValue(): string; override;
    function ReadValue(const Context: TIniFile): string; override;
    procedure SaveValue(const Context: TIniFile; const Value: string); override;
  end;

  TRegIntegerParam = class(TRegParam<Integer>)
  protected
    function DefaultEmptyValue(): Integer; override;
    function ReadValue(const Context: TRegistry): Integer; override;
    procedure SaveValue(const Context: TRegistry; const Value: Integer); override;
  end;

  TIniIntegerParam = class(TIniParam<Integer>)
  protected
    function DefaultEmptyValue(): Integer; override;
    function ReadValue(const Context: TIniFile): Integer; override;
    procedure SaveValue(const Context: TIniFile; const Value: Integer); override;
  end;

  TRegDoubleParam = class(TRegParam<Double>)
  protected
    function DefaultEmptyValue(): Double; override;
    function ReadValue(const Context: TRegistry): Double; override;
    procedure SaveValue(const Context: TRegistry; const Value: Double); override;
  end;

  TIniDoubleParam = class(TIniParam<Double>)
  protected
    function DefaultEmptyValue(): Double; override;
    function ReadValue(const Context: TIniFile): Double; override;
    procedure SaveValue(const Context: TIniFile; const Value: Double); override;
  end;

  TRegDateTimeParam = class(TRegParam<TDateTime>)
  protected
    function DefaultEmptyValue(): TDateTime; override;
    function ReadValue(const Context: TRegistry): TDateTime; override;
    procedure SaveValue(const Context: TRegistry; const Value: TDateTime); override;
  end;

  TIniDateTimeParam = class(TIniParam<TDateTime>)
  protected
    function DefaultEmptyValue(): TDateTime; override;
    function ReadValue(const Context: TIniFile): TDateTime; override;
    procedure SaveValue(const Context: TIniFile; const Value: TDateTime); override;
  end;

  TRegTimeParam = class(TRegParam<TTime>)
  protected
    function DefaultEmptyValue(): TTime; override;
    function ReadValue(const Context: TRegistry): TTime; override;
    procedure SaveValue(const Context: TRegistry; const Value: TTime); override;
  end;

  TIniTimeParam = class(TIniParam<TTime>)
  protected
    function DefaultEmptyValue(): TTime; override;
    function ReadValue(const Context: TIniFile): TTime; override;
    procedure SaveValue(const Context: TIniFile; const Value: TTime); override;
  end;

implementation

uses
  App.Constants;

constructor TCLParam<T, C>.Create;
begin
  inherited Create;

end;

constructor TCLParam<T,C>.Create(const KeyName, KeyPath: string; const EmptyValue: T);
begin
  Create;

  FKeyName := KeyName;
  FKeyPath := KeyPath;
  FEmptyValue := EmptyValue;
  FValue := EmptyValue;
end;

constructor TCLParam<T,C>.Create(const KeyName, KeyPath: string);
begin
  Create(KeyName, KeyPath, DefaultEmptyValue);
end;

destructor TCLParam<T,C>.Destroy;
begin

  inherited;
end;

function TCLParam<T,C>.GetValue: T;
begin
  Result := FValue;
end;

procedure TCLParam<T,C>.SetValue(const Value: T);
begin
  FValue := Value;
end;

{ TRegParam<T> }

constructor TRegParam<T>.Create;
begin
  inherited;

  if not Assigned(FRegistry) then begin
    FRegistry := TRegistry.Create;
    FRegistry.RootKey := HKEY_CURRENT_USER;
    FRefCount := 1;
  end
  else
    Inc(FRefCount);
end;

destructor TRegParam<T>.Destroy;
begin
  if FRefCount > 1 then
    Dec(FRefCount)
  else
    FreeAndNil(FRegistry);

  inherited;
end;

function TRegParam<T>.GetRegistryPath: string;
begin
  if AppName <> '' then
    Result := 'Software\' + AppName + '\';

  if FKeyPath = '' then
    Result := Result + 'Settings'
  else
    Result := Result + FKeyPath;
end;

function TRegParam<T>.Load(const Context: TRegistry): T;
var
  Key: string;
begin
  Key := GetRegistryPath;

  Result := FEmptyValue;
  try
    if not Context.KeyExists(Key) then
      Exit;

    Context.OpenKey(Key, False);
    try
      if Context.ValueExists(FKeyName) then
        Result := ReadValue(Context);
    finally
      Context.CloseKey;
    end;
  finally
    FValue := Result;
  end;
end;

function TRegParam<T>.Load: T;
begin
  Result := Load(FRegistry);
end;

procedure TRegParam<T>.Save(const Context: TRegistry; const Value: T);
begin
  Context.OpenKey(GetRegistryPath, True);
  try
    SaveValue(Context, Value);
    FValue := Value;
  finally
    Context.CloseKey;
  end;
end;

procedure TRegParam<T>.Save(const Context: TRegistry);
begin
  Save(Context, FValue);
end;

procedure TRegParam<T>.Save(const Value: T);
begin
  Save(FRegistry, Value);
end;

procedure TRegParam<T>.Save;
begin
  Save(FRegistry, FValue);
end;

{ TIniParam<T> }

function TIniParam<T>.Load(const Context: TIniFile): T;
begin
  Result := ReadValue(Context);
  FValue := Result;
end;

procedure TIniParam<T>.Save(const Context: TIniFile; const Value: T);
begin
  SaveValue(Context, Value);
  FValue := Value;
end;

procedure TIniParam<T>.Save(const Context: TIniFile);
begin
  Save(Context, FValue);
end;

{ TRegBooleanParam }

function TRegBooleanParam.DefaultEmptyValue: Boolean;
begin
  Result := False;
end;

function TRegBooleanParam.ReadValue(const Context: TRegistry): Boolean;
begin
  Result := Context.ReadBool(FKeyName);
end;

procedure TRegBooleanParam.SaveValue(const Context: TRegistry; const Value: Boolean);
begin
  Context.WriteBool(FKeyName, Value);
end;

{ TIniBooleanParam }

function TIniBooleanParam.DefaultEmptyValue: Boolean;
begin
  Result := False;
end;

function TIniBooleanParam.ReadValue(const Context: TIniFile): Boolean;
begin
   Result := Context.ReadBool(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TIniBooleanParam.SaveValue(const Context: TIniFile; const Value: Boolean);
begin
  Context.WriteBool(FKeyPath, FKeyName, Value);
end;

{ TRegStringParam }

function TRegStringParam.DefaultEmptyValue: string;
begin
  Result := '';
end;

function TRegStringParam.ReadValue(const Context: TRegistry): string;
begin
  Result := Context.ReadString(FKeyName);
end;

procedure TRegStringParam.SaveValue(const Context: TRegistry; const Value: string);
begin
  Context.WriteString(FKeyName, Value);
end;

{ TIniStringParam }

function TIniStringParam.DefaultEmptyValue: string;
begin
  Result := '';
end;

function TIniStringParam.ReadValue(const Context: TIniFile): string;
begin
  Result := Context.ReadString(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TIniStringParam.SaveValue(const Context: TIniFile; const Value: string);
begin
  Context.WriteString(FKeyPath, FKeyName, Value);
end;

{ TRegIntegerParam }

function TRegIntegerParam.DefaultEmptyValue: Integer;
begin
  Result := 0;
end;

function TRegIntegerParam.ReadValue(const Context: TRegistry): Integer;
begin
  Result := Context.ReadInteger(FKeyName);
end;

procedure TRegIntegerParam.SaveValue(const Context: TRegistry; const Value: Integer);
begin
  Context.WriteInteger(FKeyName, Value);
end;

{ TIniIntegerParam }

function TIniIntegerParam.DefaultEmptyValue: Integer;
begin
  Result := 0;
end;

function TIniIntegerParam.ReadValue(const Context: TIniFile): Integer;
begin
  Result := Context.ReadInteger(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TIniIntegerParam.SaveValue(const Context: TIniFile; const Value: Integer);
begin
  Context.WriteInteger(FKeyPath, FKeyName, Value);
end;

{ TRegDoubleParam }

function TRegDoubleParam.DefaultEmptyValue: Double;
begin
  Result := 0;
end;

function TRegDoubleParam.ReadValue(const Context: TRegistry): Double;
begin
  Result := Context.ReadFloat(FKeyName);
end;

procedure TRegDoubleParam.SaveValue(const Context: TRegistry; const Value: Double);
begin
  Context.WriteFloat(FKeyName, Value);
end;

{ TIniDoubleParam }

function TIniDoubleParam.DefaultEmptyValue: Double;
begin
  Result := 0;
end;

function TIniDoubleParam.ReadValue(const Context: TIniFile): Double;
begin
  Result := Context.ReadFloat(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TIniDoubleParam.SaveValue(const Context: TIniFile; const Value: Double);
begin
  Context.WriteFloat(FKeyPath, FKeyName, Value);
end;

{ TRegDateTimeParam }

function TRegDateTimeParam.DefaultEmptyValue: TDateTime;
begin
  Result := 0;
end;

function TRegDateTimeParam.ReadValue(const Context: TRegistry): TDateTime;
begin
  Result := Context.ReadDateTime(FKeyName);
end;

procedure TRegDateTimeParam.SaveValue(const Context: TRegistry; const Value: TDateTime);
begin
  Context.WriteDateTime(FKeyName, Value);
end;

{ TIniDateTimeParam }

function TIniDateTimeParam.DefaultEmptyValue: TDateTime;
begin
  Result := 0;
end;

function TIniDateTimeParam.ReadValue(const Context: TIniFile): TDateTime;
begin
  Result := Context.ReadDateTime(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TIniDateTimeParam.SaveValue(const Context: TIniFile; const Value: TDateTime);
begin
  Context.WriteDateTime(FKeyPath, FKeyName, Value);
end;

{ TRegTimeParam }

function TRegTimeParam.DefaultEmptyValue: TTime;
begin
  Result := 0;
end;

function TRegTimeParam.ReadValue(const Context: TRegistry): TTime;
begin
  Result := Context.ReadTime(FKeyName);
end;

procedure TRegTimeParam.SaveValue(const Context: TRegistry; const Value: TTime);
begin
  Context.WriteTime(FKeyName, Value);
end;

{ TIniTimeParam }

function TIniTimeParam.DefaultEmptyValue: TTime;
begin
  Result := 0;
end;

function TIniTimeParam.ReadValue(const Context: TIniFile): TTime;
begin
  Result := Context.ReadTime(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TIniTimeParam.SaveValue(const Context: TIniFile; const Value: TTime);
begin
  Context.WriteTime(FKeyPath, FKeyName, Value);
end;

end.

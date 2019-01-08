{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Params;

interface

uses
  Winapi.Windows, Vcl.Forms, System.SysUtils, System.Variants, System.Classes,
  Registry, IniFiles;

type
   TCLParam<T> = class(TPersistent)
   private
     FValue: T;
     FEmptyValue: T;
     FKeyName: string;
     FKeyPath: string;
   protected
     function GetValue(): T;
     procedure SetValue(const Value: T);

     function DefaultEmptyValue(): T; virtual; abstract;
     function ReadValue(const Registry: TRegistry): T; overload; virtual; abstract;
     procedure SaveValue(const Registry: TRegistry; const Value: T); overload; virtual; abstract;
     function ReadValue(const IniFile: TIniFile): T; overload; virtual; abstract;
     procedure SaveValue(const IniFile: TIniFile; const Value: T); overload; virtual; abstract;
   public
     constructor Create(const KeyName, KeyPath: string; const EmptyValue: T); overload;
     constructor Create(const KeyName, KeyPath: string); overload;
     destructor Destroy; override;

     function Load(const Registry: TRegistry): T; overload;
     procedure Save(const Registry: TRegistry; const Value: T); overload;
     procedure Save(const Registry: TRegistry); overload;
     function Load(const IniFile: TIniFile): T; overload;
     procedure Save(const IniFile: TIniFile; const Value: T); overload;
     procedure Save(const IniFile: TIniFile); overload;

     property KeyName: string read FKeyName write FKeyName;
     property KeyPath: string read FKeyPath write FKeyPath;
     property Value: T read GetValue write SetValue;
   end;

   TBooleanParam = class(TCLParam<Boolean>)
   protected
     function DefaultEmptyValue(): Boolean; override;
     function ReadValue(const Registry: TRegistry): Boolean; overload; override;
     procedure SaveValue(const Registry: TRegistry; const Value: Boolean); overload; override;
     function ReadValue(const IniFile: TIniFile): Boolean; overload; override;
     procedure SaveValue(const IniFile: TIniFile; const Value: Boolean); overload; override;
   end;

   TStringParam = class(TCLParam<string>)
   protected
     function DefaultEmptyValue(): string; override;
     function ReadValue(const Registry: TRegistry): string; overload; override;
     procedure SaveValue(const Registry: TRegistry; const Value: string); overload; override;
     function ReadValue(const IniFile: TIniFile): string; overload; override;
     procedure SaveValue(const IniFile: TIniFile; const Value: string); overload; override;
   end;

   TIntegerParam = class(TCLParam<Integer>)
   protected
     function DefaultEmptyValue(): Integer; override;
     function ReadValue(const Registry: TRegistry): Integer; overload; override;
     procedure SaveValue(const Registry: TRegistry; const Value: Integer); overload; override;
     function ReadValue(const IniFile: TIniFile): Integer; overload; override;
     procedure SaveValue(const IniFile: TIniFile; const Value: Integer); overload; override;
   end;

   TDoubleParam = class(TCLParam<Double>)
   protected
     function DefaultEmptyValue(): Double; override;
     function ReadValue(const Registry: TRegistry): Double; overload; override;
     procedure SaveValue(const Registry: TRegistry; const Value: Double); overload; override;
     function ReadValue(const IniFile: TIniFile): Double; overload; override;
     procedure SaveValue(const IniFile: TIniFile; const Value: Double); overload; override;
   end;

   TDateTimeParam = class(TCLParam<TDateTime>)
   protected
     function DefaultEmptyValue(): TDateTime; override;
     function ReadValue(const Registry: TRegistry): TDateTime; overload; override;
     procedure SaveValue(const Registry: TRegistry; const Value: TDateTime); overload; override;
     function ReadValue(const IniFile: TIniFile): TDateTime; overload; override;
     procedure SaveValue(const IniFile: TIniFile; const Value: TDateTime); overload; override;
   end;

implementation

constructor TCLParam<T>.Create(const KeyName, KeyPath: string; const EmptyValue: T);
begin
  inherited Create();

  FKeyName := KeyName;
  FKeyPath := KeyPath;
  FEmptyValue := EmptyValue;
  FValue := EmptyValue;
end;

constructor TCLParam<T>.Create(const KeyName, KeyPath: string);
begin
  Create(KeyName, KeyPath, DefaultEmptyValue);
end;

destructor TCLParam<T>.Destroy;
begin

  inherited;
end;

function TCLParam<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TCLParam<T>.SetValue(const Value: T);
begin
  FValue := Value;
end;

function TCLParam<T>.Load(const Registry: TRegistry): T;
begin
  Result := FEmptyValue;
  try
    if not Registry.KeyExists(FKeyPath) then
      Exit;

    Registry.OpenKey(FKeyPath, False);
    try
      if Registry.ValueExists(FKeyName) then
        Result := ReadValue(Registry);
    finally
      Registry.CloseKey;
    end;
  finally
    FValue := Result;
  end;
end;

procedure TCLParam<T>.Save(const Registry: TRegistry; const Value: T);
begin
  Registry.OpenKey(FKeyPath, True);
  try
    SaveValue(Registry, Value);
    FValue := Value;
  finally
    Registry.CloseKey;
  end;
end;

procedure TCLParam<T>.Save(const Registry: TRegistry);
begin
  Save(Registry, FValue);
end;

function TCLParam<T>.Load(const IniFile: TIniFile): T;
begin
  try
    Result := ReadValue(IniFile);
  finally
    FValue := Result;
  end;
end;

procedure TCLParam<T>.Save(const IniFile: TIniFile; const Value: T);
begin
  SaveValue(IniFile, Value);
  FValue := Value;
end;

procedure TCLParam<T>.Save(const IniFile: TIniFile);
begin
  Save(IniFile, FValue);
end;

{ TBooleanParam }

function TBooleanParam.DefaultEmptyValue: Boolean;
begin
  Result := False;
end;

function TBooleanParam.ReadValue(const Registry: TRegistry): Boolean;
begin
  Result := Registry.ReadBool(FKeyName);
end;

procedure TBooleanParam.SaveValue(const Registry: TRegistry; const Value: Boolean);
begin
  Registry.WriteBool(FKeyName, Value);
end;

function TBooleanParam.ReadValue(const IniFile: TIniFile): Boolean;
begin
  Result := IniFile.ReadBool(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TBooleanParam.SaveValue(const IniFile: TIniFile; const Value: Boolean);
begin
  IniFile.WriteBool(FKeyPath, FKeyName, Value);
end;

{ TStringParam }

function TStringParam.DefaultEmptyValue: string;
begin
  Result := '';
end;

function TStringParam.ReadValue(const Registry: TRegistry): string;
begin
  Result := Registry.ReadString(FKeyName);
end;

procedure TStringParam.SaveValue(const Registry: TRegistry; const Value: string);
begin
  Registry.WriteString(FKeyName, Value);
end;

function TStringParam.ReadValue(const IniFile: TIniFile): string;
begin
  Result := IniFile.ReadString(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TStringParam.SaveValue(const IniFile: TIniFile; const Value: string);
begin
  IniFile.WriteString(FKeyPath, FKeyName, Value);
end;

{ TIntegerParam }

function TIntegerParam.DefaultEmptyValue: Integer;
begin
  Result := 0;
end;

function TIntegerParam.ReadValue(const Registry: TRegistry): Integer;
begin
  Result := Registry.ReadInteger(FKeyName);
end;

procedure TIntegerParam.SaveValue(const Registry: TRegistry; const Value: Integer);
begin
  Registry.WriteInteger(FKeyName, Value);
end;

function TIntegerParam.ReadValue(const IniFile: TIniFile): Integer;
begin
  Result := IniFile.ReadInteger(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TIntegerParam.SaveValue(const IniFile: TIniFile; const Value: Integer);
begin
  IniFile.WriteInteger(FKeyPath, FKeyName, Value);
end;

{ TDoubleParam }

function TDoubleParam.DefaultEmptyValue: Double;
begin
  Result := 0;
end;

function TDoubleParam.ReadValue(const Registry: TRegistry): Double;
begin
  Result := Registry.ReadFloat(FKeyName);
end;

procedure TDoubleParam.SaveValue(const Registry: TRegistry; const Value: Double);
begin
  Registry.WriteFloat(FKeyName, Value);
end;

function TDoubleParam.ReadValue(const IniFile: TIniFile): Double;
begin
  Result := IniFile.ReadFloat(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TDoubleParam.SaveValue(const IniFile: TIniFile; const Value: Double);
begin
  IniFile.WriteFloat(FKeyPath, FKeyName, Value);
end;

{ TDateTimeParam }

function TDateTimeParam.DefaultEmptyValue: TDateTime;
begin
  Result := 0;
end;

function TDateTimeParam.ReadValue(const Registry: TRegistry): TDateTime;
begin
  Result := Registry.ReadDateTime(FKeyName);
end;

procedure TDateTimeParam.SaveValue(const Registry: TRegistry; const Value: TDateTime);
begin
  Registry.WriteDateTime(FKeyName, Value);
end;

function TDateTimeParam.ReadValue(const IniFile: TIniFile): TDateTime;
begin
  Result := IniFile.ReadDateTime(FKeyPath, FKeyName, FEmptyValue);
end;

procedure TDateTimeParam.SaveValue(const IniFile: TIniFile; const Value: TDateTime);
begin
  IniFile.WriteDateTime(FKeyPath, FKeyName, Value);
end;

end.

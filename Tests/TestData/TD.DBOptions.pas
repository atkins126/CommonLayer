unit TD.DBOptions;

interface

uses
  System.Classes, System.SysUtils, System.Variants, IniFiles, App.Options,
  App.Params, App.DB.Options, Registry;

type
  TDBOptions = class(TCLDBOptions)
  private
    FBooleanParam: TRegBooleanParam;
    FIntegerParam: TRegIntegerParam;
    FStringParam: TRegStringParam;
    FDoubleParam: TRegDoubleParam;
    FDateTimeParam: TRegDateTimeParam;

    function GetBooleanParam: Boolean;
    procedure SetBooleanParam(const Value: Boolean);
    function GetIntegerParam: Integer;
    procedure SetIntegerParam(const Value: Integer);
    function GetStringParam: string;
    procedure SetStringParam(const Value: string);
    function GetDoubleParam: Double;
    procedure SetDoubleParam(const Value: Double);
    function GetDateTimeParam: TDateTime;
    procedure SetDateTimeParam(const Value: TDateTime);
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

//    procedure Load(const Registry: TRegistry); overload; override;
//    procedure Load(const IniFile: TIniFile); overload; override;
//    procedure Save(const Registry: TRegistry); overload; override;
//    procedure Save(const IniFile: TIniFile); overload; override;

    property BooleanParam: Boolean read GetBooleanParam write SetBooleanParam;
    property IntegerParam: Integer read GetIntegerParam write SetIntegerParam;
    property StringParam: string read GetStringParam write SetStringParam;
    property DoubleParam: Double read GetDoubleParam write SetDoubleParam;
    property DateTimeParam: TDateTime read GetDateTimeParam write SetDateTimeParam;
  end;

implementation

const
  TestGroupName = 'Test';
  BooleanParamName = 'BooleanParam';
  IntegerParamName = 'IntegerParam';
  StringParamName = 'StringParam';
  DoubleParamName = 'DoubleParam';
  DateTimeParamName = 'DateTimeParam';

{ TDBOptions }

constructor TDBOptions.Create(Owner: TComponent);
begin
  inherited;

//  FBooleanParam := TBooleanParam.Create(BooleanParamName, TestGroupName);
//  FIntegerParam := TIntegerParam.Create(IntegerParamName, TestGroupName);
//  FStringParam := TStringParam.Create(StringParamName, TestGroupName);
//  FDoubleParam := TDoubleParam.Create(DoubleParamName, TestGroupName);
//  FDateTimeParam := TDateTimeParam.Create(DateTimeParamName, TestGroupName);
end;

destructor TDBOptions.Destroy;
begin
  FBooleanParam.Free;
  FIntegerParam.Free;
  FStringParam.Free;
  FDoubleParam.Free;
  FDateTimeParam.Free;

  inherited;
end;

function TDBOptions.GetBooleanParam: Boolean;
begin
  Result := FBooleanParam.Value;
end;

procedure TDBOptions.SetBooleanParam(const Value: Boolean);
begin
  FBooleanParam.Value := Value;
end;

function TDBOptions.GetIntegerParam: Integer;
begin
  Result := FIntegerParam.Value;
end;

procedure TDBOptions.SetIntegerParam(const Value: Integer);
begin
  FIntegerParam.Value := Value;
end;

function TDBOptions.GetStringParam: string;
begin
  Result := FStringParam.Value;
end;

procedure TDBOptions.SetStringParam(const Value: string);
begin
  FStringParam.Value := Value;
end;

function TDBOptions.GetDoubleParam: Double;
begin
  Result := FDoubleParam.Value;
end;

procedure TDBOptions.SetDoubleParam(const Value: Double);
begin
  FDoubleParam.Value := Value;
end;

function TDBOptions.GetDateTimeParam: TDateTime;
begin
  Result := FDateTimeParam.Value;
end;

procedure TDBOptions.SetDateTimeParam(const Value: TDateTime);
begin
  FDateTimeParam.Value := Value;
end;

//procedure TDBOptions.Load(const Registry: TRegistry);
//begin
//  FBooleanParam.Load(Registry);
//  FIntegerParam.Load(Registry);
//  FStringParam.Load(Registry);
//  FDoubleParam.Load(Registry);
//  FDateTimeParam.Load(Registry);
//end;
//
//procedure TDBOptions.Load(const IniFile: TIniFile);
//begin
//  FBooleanParam.Load(IniFile);
//  FIntegerParam.Load(IniFile);
//  FStringParam.Load(IniFile);
//  FDoubleParam.Load(IniFile);
//  FDateTimeParam.Load(IniFile);
//end;
//
//procedure TDBOptions.Save(const IniFile: TIniFile);
//begin
//  FBooleanParam.Save(IniFile);
//  FIntegerParam.Save(IniFile);
//  FStringParam.Save(IniFile);
//  FDoubleParam.Save(IniFile);
//  FDateTimeParam.Load(IniFile);
//end;
//
//procedure TDBOptions.Save(const Registry: TRegistry);
//begin
//  FBooleanParam.Save(Registry);
//  FIntegerParam.Save(Registry);
//  FStringParam.Save(Registry);
//  FDoubleParam.Save(Registry);
//  FDateTimeParam.Load(Registry);
//end;

end.

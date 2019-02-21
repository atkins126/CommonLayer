unit TD.DBOptions;

interface

uses
  System.Classes, System.SysUtils, System.Variants, IniFiles, App.Options,
  App.Params, App.DB.Options;

type
  TDBOptions = class(TCLDBOptions)
  private
    FBooleanParam: TBooleanParam;
    FIntegerParam: TIntegerParam;
    FStringParam: TStringParam;
    FDoubleParam: TDoubleParam;
    FDateTimeParam: TDateTimeParam;

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

    procedure LoadFromIniFile(const IniFile: TIniFile); override;
    procedure SaveToIniFile(const IniFile: TIniFile); override;

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

  FBooleanParam := TBooleanParam.Create(BooleanParamName, TestGroupName);
  FIntegerParam := TIntegerParam.Create(IntegerParamName, TestGroupName);
  FStringParam := TStringParam.Create(StringParamName, TestGroupName);
  FDoubleParam := TDoubleParam.Create(DoubleParamName, TestGroupName);
  FDateTimeParam := TDateTimeParam.Create(DateTimeParamName, TestGroupName);
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

procedure TDBOptions.LoadFromIniFile(const IniFile: TIniFile);
begin
  inherited;

  FBooleanParam.Load(IniFile);
  FIntegerParam.Load(IniFile);
  FStringParam.Load(IniFile);
  FDoubleParam.Load(IniFile);
  FDateTimeParam.Load(IniFile);
end;

procedure TDBOptions.SaveToIniFile(const IniFile: TIniFile);
begin
  inherited;

  FBooleanParam.Save(IniFile);
  FIntegerParam.Save(IniFile);
  FStringParam.Save(IniFile);
  FDoubleParam.Save(IniFile);
  FDateTimeParam.Load(IniFile);
end;

end.

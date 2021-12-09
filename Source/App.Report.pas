{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.Report;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Variants,
  frxClass, frxDesgn, dmuFastReportExport, App.Params;

type
  TAfterLoadEvent = procedure (Report: TfrxReport) of object;

  TExportFileFormat = (effWord, effExcelOLE, effExcelXML, effPDF, effHTML,
                       effTXT, effJPEG, effExcelByTemplate);

  TCLReport = class(TDataModule)
  private
    FInternalReport: TfrxReport;
    FDesigner: TfrxDesigner;
    FReportExport: TdmFastReportExport;

    FReportFileName: TRegStringParam;

    FOnAfterLoad: TAfterLoadEvent;

    procedure SetInternalReport(const Value: TfrxReport);
    function GetStorageFolder: string;
    function GetReportFileName: string;
    procedure SetReportFileName(const Value: string);
  protected
    function GetReport: TfrxReport; virtual; abstract;
    function GetReportName: string; virtual; abstract;

    procedure OnShowReport(Sender: TObject);

    property InternalReport: TfrxReport read FInternalReport write SetInternalReport;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Print(const Preview: Boolean);
    procedure DoPrint(ShowDialog: Boolean);
    procedure EditReport;
    function CopyReportToFolder(const FileName: string): string;
    function ExportReportToRTF(Report: TfrxReport; const Key, PathName, FileName: string): Boolean;
    function ExportReportToFilePrim(Report: TfrxReport; constKey, aPathName, aFileName: string;
                                    FileFormat: TExportFileFormat): Boolean;

    procedure AddNewVariable(const Category, Name: string);

    property Report: TfrxReport read GetReport;
    property ReportName: string read GetReportName;
    property ReportFileName: string read GetReportFileName write SetReportFileName;
    property StorageFolder: string read GetStorageFolder;

    property OnAfterLoad: TAfterLoadEvent read FOnAfterLoad write FOnAfterLoad;
  end;

implementation

uses
  App.Constants;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TCLReport }

constructor TCLReport.Create(AOwner: TComponent);
const
  CurrentReportParamName = 'ReportParamName';
begin
  inherited;

  FInternalReport := TfrxReport.Create(Self);
  InternalReport.OnGetValue := Report.OnGetValue;
  FOnAfterLoad := nil;

  FDesigner := TfrxDesigner.Create(Self);
  FDesigner.TemplateDir := StorageFolder;
  FDesigner.OpenDir := StorageFolder;
  FDesigner.SaveDir := StorageFolder;

  FReportExport := TdmFastReportExport.Create(Self);

  FReportFileName := TRegStringParam.Create(CurrentReportParamName, ReportName, '');
  FReportFileName.Load;

  ForceDirectories(StorageFolder);
end;

destructor TCLReport.Destroy;
begin
  FOnAfterLoad := nil;
  FInternalReport.Free;
  FDesigner.Free;
  FReportExport.Free;
  FReportFileName.Free;

  inherited;
end;

procedure TCLReport.SetInternalReport(const Value: TfrxReport);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Value.SaveToStream(Stream);
    Stream.Position := 0;
    FInternalReport.LoadFromStream(Stream);
    FInternalReport.OnGetValue := Value.OnGetValue;
  finally
    Stream.Free;
  end;
end;

function TCLReport.GetStorageFolder: string;
const
  ReportFolder = 'Report';
begin
  Result := IncludeTrailingPathDelimiter(AppPath) + ReportFolder;
end;

function TCLReport.GetReportFileName: string;
begin
  Result := FReportFileName.Value;
end;

procedure TCLReport.SetReportFileName(const Value: string);
begin
  if FReportFileName.Value <> Value then begin
    FReportFileName.Value := Value;
    FReportFileName.Save;
  end;
end;

procedure TCLReport.DoPrint(ShowDialog: Boolean);
var
  FileName: string;
begin
  FileName := IncludeTrailingPathDelimiter(StorageFolder) + ReportFileName;
  if FileExists(FileName) then
    FInternalReport.LoadFromFile(FileName)
  else
    InternalReport := Report;

  if Assigned(FOnAfterLoad) then
    FOnAfterLoad(FInternalReport);

  FInternalReport.PrintOptions.ShowDialog := ShowDialog;
  FInternalReport.PrepareReport;
  FInternalReport.Print;
end;

procedure TCLReport.OnShowReport(Sender: TObject);
var
  FileName: string;
begin
  FileName := IncludeTrailingPathDelimiter(StorageFolder) + ReportFileName;
  if FileExists(FileName) then
    FInternalReport.LoadFromFile(FileName)
  else
    InternalReport := Report;

  if Assigned(FOnAfterLoad) then
    FOnAfterLoad(FInternalReport);

  FInternalReport.ShowReport;
end;

function TCLReport.CopyReportToFolder(const FileName: string): string;
begin
  if SameText(ExtractFileDir(FileName), StorageFolder) then
    Exit(FileName);

  Result := IncludeTrailingPathDelimiter(StorageFolder) + ExtractFileName(FileName);
  ForceDirectories(StorageFolder);
  CopyFile(PWideChar(FileName), PWideChar(Result), False);
end;

procedure TCLReport.Print(const Preview: Boolean);
begin
  if Preview then
    OnShowReport(nil)
  else
    DoPrint(False);
end;

procedure TCLReport.EditReport;
var
  FileName: string;
  NewFileName: string;
begin
  FileName := IncludeTrailingPathDelimiter(StorageFolder) + ReportFileName;
  if FileExists(FileName) then begin
    FInternalReport.LoadFromFile(FileName);
    FInternalReport.FileName := FileName;
  end
  else begin
    InternalReport.FileName := '';
    InternalReport := Report;
  end;

  frxDesignerComp.SaveDir := StorageFolder;

  if Assigned(FOnAfterLoad) then
    FOnAfterLoad(FInternalReport);

  FInternalReport.DesignReport;
  if (FInternalReport.FileName <> '') and (FInternalReport.FileName <> FileName) then begin
    NewFileName := CopyReportToFolder(FInternalReport.FileName);
    ReportFileName := ExtractFileName(NewFileName);
  end;
end;

procedure TCLReport.AddNewVariable(const Category, Name: string);
begin
  if InternalReport.Variables.IndexOf(Name) = -1 then
    InternalReport.Variables.AddVariable(Category, Name, Null);

  if InternalReport.Variables.IndexOf(Name) = -1 then
    InternalReport.Variables.Add.Name := Name;
end;

function TCLReport.ExportReportToRTF(Report: TfrxReport; const Key, PathName,
  FileName: string): Boolean;
begin
//  {установить текущим каталог исполняемого файла для сохранения шаблона}
//  cbReportPath.Text:= CurrentReportFileName;
//  cbReportPath.Items.CommaText:= ReportFileNameList;
//
//  {копируем отчет}
//  CopyReport(aReport);
//
//  if Validate(sError)
//  then {указан шаблон отчета}
//  begin
//     {загружаем шаблон}
//     frxReport.LoadFromFile(GetFileName);
//  end;
//
//  if not DirectoryExists(aPathName)
//  then {не существует директория}
//  begin
//     CreateDir(aPathName);
//  end;
//
//  FReportExport.frxRTFExport.FileName:= aPathName + '\' + aFileName;
//  FReportExport.frxRTFExport.ShowDialog:= False;
//  FReportExport.frxRTFExport.OpenAfterExport:= False;
//  FReportExport.frxRTFExport.ShowProgress:= False;
//
//  {подготавливаем отчет}
//  frxReport.PrepareReport;
//  Result:= frxReport.Export(FReportExport.frxRTFExport);
  Result := False;
end;

function TCLReport.ExportReportToFilePrim(Report: TfrxReport; constKey,
  aPathName, aFileName: string; FileFormat: TExportFileFormat): Boolean;
begin
//   {установить текущим каталог исполняемого файла для сохранения шаблона}
//   cbReportPath.Text:= ReportFileNameList;
//   cbReportPath.Items.CommaText:= ReportFileNameList;
//
//   {копируем отчет}
//   CopyReport(aReport);
//
//   if Validate(sError)
//   then {указан шаблон отчета}
//   begin
//      {загружаем шаблон}
//      frxReport.LoadFromFile(GetFileName);
//   end;
//
//   if not DirectoryExists(aPathName)
//   then {не существует директория}
//   begin
//      CreateDir(aPathName);
//   end;
//
//   {подготавливаем отчет}
//   frxReport.PrepareReport;
//
//   {выбираем в какой тип файла экспортировать отчет}
//   case aFileFormat of
//      effWord:
//      begin
//         FReportExport.frxRTFExport.FileName:= aPathName + '\' + aFileName;
//         FReportExport.frxRTFExport.ShowDialog:= False;
//         FReportExport.frxRTFExport.OpenAfterExport:= False;
//         FReportExport.frxRTFExport.ShowProgress:= False;
//         Result:= frxReport.Export(FReportExport.frxRTFExport);
//      end;
//      effExcelOLE:
//      begin
//         FReportExport.frxXLSExport.FileName:= aPathName + '\' + aFileName;
//         FReportExport.frxXLSExport.ShowDialog:= False;
//         FReportExport.frxXLSExport.OpenExcelAfterExport:= False;
//         FReportExport.frxXLSExport.ShowProgress:= False;
//         Result:= frxReport.Export(FReportExport.frxXLSExport);
//      end;
//      effExcelXML:
//      begin
//         FReportExport.frxXMLExport.FileName:= aPathName + '\' + aFileName;
//         FReportExport.frxXMLExport.ShowDialog:= False;
//         FReportExport.frxXMLExport.OpenExcelAfterExport:= False;
//         FReportExport.frxXMLExport.ShowProgress:= False;
//         Result:= frxReport.Export(FReportExport.frxXMLExport);
//      end;
//      effPDF:
//      begin
//         FReportExport.frxPDFExport.FileName:= aPathName + '\' + aFileName;
//         FReportExport.frxPDFExport.ShowDialog:= False;
//         FReportExport.frxPDFExport.OpenAfterExport:= False;
//         FReportExport.frxPDFExport.ShowProgress:= False;
//         Result:= frxReport.Export(FReportExport.frxPDFExport);
//      end;
//      effHTML:
//      begin
//         FReportExport.frxHTMLExport.FileName:= aPathName + '\' + aFileName;
//         FReportExport.frxHTMLExport.ShowDialog:= False;
//         FReportExport.frxHTMLExport.OpenAfterExport:= False;
//         FReportExport.frxHTMLExport.ShowProgress:= False;
//         Result:= frxReport.Export(FReportExport.frxHTMLExport);
//      end;
//      effTXT:
//      begin
//         FReportExport.frxSimpleTextExport.FileName:= aPathName + '\' + aFileName;
//         FReportExport.frxSimpleTextExport.ShowDialog:= False;
//         FReportExport.frxSimpleTextExport.OpenAfterExport:= False;
//         FReportExport.frxSimpleTextExport.ShowProgress:= False;
//         Result:= frxReport.Export(FReportExport.frxSimpleTextExport);
//      end;
//      effJPEG:
//      begin
//         FReportExport.frxJPEGExport.FileName:= aPathName + '\' + aFileName;
//         FReportExport.frxJPEGExport.ShowDialog:= False;
//         FReportExport.frxJPEGExport.ShowProgress:= False;
//         FReportExport.frxJPEGExport.SeparateFiles:= False;
//         Result:= frxReport.Export(FReportExport.frxJPEGExport);
//      end;
//      effExcelByTemplate:
//      begin
//         {не экспортировать отсюда}
//         Result:= False;
//      end;
//   end;
end;

end.

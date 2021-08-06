{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2021 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.XMLFile;

interface

uses
  Vcl.Forms, System.SysUtils, System.Variants, System.Classes, Winapi.ActiveX,
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc, System.Win.ComObj;

type
  TXMLFile = class(TObject)
  private
    FDocument: IXMLDocument;
    FRoot: IXMLNode;
    FFileName: string;

    procedure SaveToFile();
  public
    constructor Create(const FileName: string; const Rewrite: Boolean);
    destructor Destroy(); override;

    property Document: IXMLDocument read FDocument;
    property Root: IXMLNode read FRoot;
  end;

implementation

{ TXMLFile }

constructor TXMLFile.Create(const FileName: string; const Rewrite: Boolean);
begin
  inherited Create();

  FFileName := FileName;

  CoInitialize(nil);
  FDocument := TXMLDocument.Create(Application);
  FDocument.Active := True;

  FDocument.Version :='1.0';
  FDocument.Encoding := 'windows-1251';

  if Rewrite then
  begin
    FRoot := FDocument.AddChild('root');
    FDocument.Options := FDocument.Options + [doNodeAutoIndent];
    SaveToFile();
  end
  else
  begin
    FDocument.LoadFromFile(FFileName);
    FRoot:= FDocument.ChildNodes.Nodes['root'];
    FDocument.Options := FDocument.Options + [doNodeAutoIndent];
  end;
end;

destructor TXMLFile.Destroy;
begin
  FRoot := nil;
  FDocument := nil;

  CoUninitialize;

  inherited;
end;

procedure TXMLFile.SaveToFile;
begin
  if Assigned(FDocument) and FDocument.Active then
    FDocument.SaveToFile(FFileName);
end;

end.

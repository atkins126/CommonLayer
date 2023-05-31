{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.ComponentIO;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Data.DB, FireDAC.Comp.Client;

type
  TObjReader = class(TReader)
  end;

  TFileSaveFormat = (fsfBinary, fsfText);

  TComponentIO = class
  public
    class procedure ReadFromStream(Source: TStream; Dest: TComponent; Format: TFileSaveFormat);
    class procedure WriteToStream(Source: TComponent; Dest: TStream; Format: TFileSaveFormat);

    class procedure ReadFromFile(const FileName: string; Dest: TComponent; Format: TFileSaveFormat);
    class procedure WriteToFile(Source: TComponent; const FileName: string; Format: TFileSaveFormat);

    class procedure ReadFromField(Source: TBlobField; Dest: TPersistent);
    class procedure WriteToDB(Source: TPersistent; Query: TFDQuery; const ParamName: string);

    class function GetObjectString(Source: TPersistent): string;

    class procedure ReadFromString(const Source: string; Dest: TComponent; Format: TFileSaveFormat);
    class function WriteToString(Source: TComponent; Format: TFileSaveFormat): string;
  end;

implementation

{ TComponentIO }

class procedure TComponentIO.ReadFromStream(Source: TStream; Dest: TComponent; Format: TFileSaveFormat);
var
  Buf: TMemoryStream;
begin
  case Format of
    fsfText: begin
      Buf := TMemoryStream.Create;
      try
        ObjectTextToBinary(Source, Buf);
        Buf.Position := 0;
        Buf.ReadComponent(Dest);
      finally
        Buf.Free;
      end;
    end;
    else
      Source.ReadComponent(Dest);
  end;
end;

class procedure TComponentIO.WriteToStream(Source: TComponent; Dest: TStream; Format: TFileSaveFormat);
var
  Buf: TMemoryStream;
begin
  case Format of
    fsfText: begin
      Buf := TMemoryStream.Create;
      try
        Buf.WriteComponent(Source);
        Buf.Position := 0;
        ObjectBinaryToText(Buf, Dest);
      finally
        Buf.Free;
      end;
    end;
    else
      Dest.WriteComponent(Source);
  end;
end;

class procedure TComponentIO.ReadFromFile(const FileName: string; Dest: TComponent; Format: TFileSaveFormat);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    ReadFromStream(Stream, Dest, Format);
  finally
    Stream.Free;
  end;
end;

class procedure TComponentIO.WriteToFile(Source: TComponent; const FileName: string; Format: TFileSaveFormat);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate or fmOpenWrite);
  try
    WriteToStream(Source, Stream, Format);
  finally
    Stream.Free;
  end;
end;

class procedure TComponentIO.ReadFromField(Source: TBlobField; Dest: TPersistent);

  procedure Action(Source: TStream; Dest: TPersistent);
  var
    Reader: TObjReader;
  begin
    Source.Position := 0;
    Reader := TObjReader.Create(Source, 64);
    try
      while Reader.Position < Source.Size do begin
        try
          Reader.ReadProperty(Dest);
        except
          Break;
        end;
      end;
    finally
      Reader.Free;
    end;
  end;

var
  Buf: TMemoryStream;
begin
  if ((not Source.DataSet.Active) or (Source.IsNull) or (Source.AsString = '')) then
    Exit;

  Buf := TMemoryStream.Create;
  try
    Source.SaveToStream(Buf);
    Action(Buf, Dest);
  finally
    Buf.Free;
  end;
end;

class procedure TComponentIO.WriteToDB(Source: TPersistent; Query: TFDQuery; const ParamName: string);

  procedure Action(Source: TPersistent; Dest: TStream);
  var
    Writer: TWriter;
  begin
    Writer := TWriter.Create(Dest, 1024);
    try
      Writer.WriteProperties(Source);
    finally
      Writer.Free;
    end;
  end;

var
  Buf: TMemoryStream;
begin
  Buf := TMemoryStream.Create;
  try
    Action(Source, Buf);

    Buf.Position := 0;
    Query.ParamByName(ParamName).LoadFromStream(Buf, ftBlob);
  finally
    Buf.Free;
  end;
end;

class function TComponentIO.GetObjectString(Source: TPersistent): string;

  procedure Action(Source: TPersistent; Dest: TStream);
  var
    Writer: TWriter;
  begin
    Writer := TWriter.Create(Dest, 1024);
    try
      Writer.WriteProperties(Source);
    finally
      Writer.Free;
    end;
  end;

var
  Buf: TStringStream;
begin
  Buf := TStringStream.Create;
  try
    Action(Source, Buf);

    Buf.Position := 0;
    Result := Buf.DataString;
  finally
    Buf.Free;
  end;
end;

class procedure TComponentIO.ReadFromString(const Source: string; Dest: TComponent; Format: TFileSaveFormat);
var
  Buf: TStringStream;
begin
  Buf := TStringStream.Create(Source);
  try
    Buf.Position := 0;
    ReadFromStream(Buf, Dest, Format);
  finally
    Buf.Free;
  end;
end;

class function TComponentIO.WriteToString(Source: TComponent; Format: TFileSaveFormat): string;
var
  Buf: TStringStream;
begin
  Buf := TStringStream.Create;
  try
    WriteToStream(Source, Buf, Format);
    Result := Buf.DataString;
  finally
    Buf.Free;
  end;
end;

end.

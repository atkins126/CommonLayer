{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.SQLite.Connection;

interface

uses
  System.Classes, System.SysUtils, System.Variants, App.DB.Connection,
  {$IFDEF UNIDAC}UniProvider, SQLiteUniProvider,{$ENDIF}
  {$IFDEF FIREDAC}FireDAC.Phys.SQLite,{$ENDIF}
  {$I DB_Links.inc};

type
  TCLSQLiteConnection = class(TCLDBConnection)
  private
  protected
    procedure DoConnect(const Connection: TDBConnection); override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy(); override;

    function IsTableExists(const TableName: string): Boolean; override;
  end;

implementation

{ TCLSQLiteConnection }

constructor TCLSQLiteConnection.Create(Owner: TComponent);
begin
  inherited;

end;

destructor TCLSQLiteConnection.Destroy;
begin

  inherited;
end;

procedure TCLSQLiteConnection.DoConnect(const Connection: TDBConnection);
begin
  FConnectionStatus := cnNone;
  Connection.Close;

{$IFDEF FIREDAC}
  raise Exception.Create('Not implemented');
{$ENDIF}

{$IFDEF UNIDAC}
  Connection.ProviderName := 'SQLite';
  Connection.Database := Database;
  Connection.SpecificOptions.Values['Direct'] := 'True';
  Connection.SpecificOptions.Values['UseUnicode'] := 'True';
{$ENDIF}

  Connection.Connected := True;
end;

function TCLSQLiteConnection.IsTableExists(const TableName: string): Boolean;
var
  Q: TDBQuery;
begin
  Q := CreateQuery(Self);
  try
    Q.SQL.Text :=
      ' SELECT Count(Name) as HasTable ' +
      ' FROM sqlite_master ' +
      ' WHERE name = "' + TableName + '"';
    Q.Open;

    Result := Q.FieldByName('HasTable').AsInteger = 1;
  finally
    Q.Free;
  end;
end;

end.

{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Types;

interface

uses
  Data.DB,
{$IFDEF FIREDAC}
  FireDAC.Comp.Client;
{$ENDIF}

{$IFDEF UNIDAC}
  MemDS, DBAccess, Uni;
{$ENDIF}

type
{$IFDEF FIREDAC}
  TDBConnection = class(TFDConnection)
  end;

  TDBQuery = class(TFDQuery)
  end;

  TDBStoredProc = class(TFDStoredProc)
  end;
{$ELSE}
//  TDBConnection = class of TUniConnection;
  TDBConnection = class(TUniConnection)
  end;

  TDBQuery = class(TUniQuery)
  end;

  TDBStoredProc = class(TUniStoredProc)
  end;
{$ENDIF}

implementation

end.

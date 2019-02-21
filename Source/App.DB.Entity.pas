{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2019 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Entity;

interface

uses
  System.Classes, System.SysUtils, System.Variants;

type
  TEntityAttribute = class(TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(const Name: String);

    property Name: String read FName write FName;
  end;

  TColumnAttribute = class(TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(const Name: String);

    property Name: String read FName write FName;
  end;

  TIDAttribute = class(TCustomAttribute)
  end;

  TEntityClass = class of TEntity;

  TEntity = class(TPersistent)
  private
    FID: Variant;
  protected
  public
    constructor Create();
    destructor Destroy(); override;

    class function EntityName(): String; virtual; abstract;
    class function FieldList(): String; virtual; abstract;
  published
    [TIDAttribute]
    [TColumnAttribute('ID')]
    property ID: Variant read FID write FID;
  end;

implementation

{ TEntityAttribute }

constructor TEntityAttribute.Create(const Name: String);
begin
  inherited Create();

  FName := Name;
end;

{ TColumnAttribute }

constructor TColumnAttribute.Create(const Name: String);
begin

end;

{ TEntity }

constructor TEntity.Create();
begin
  inherited;

  FID := Null;
end;

destructor TEntity.Destroy;
begin

  inherited;
end;

end.

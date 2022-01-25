{*******************************************************}
{                                                       }
{       Common layer of project                         }
{                                                       }
{       Copyright (c) 2018 - 2022 Sergey Lubkov         }
{                                                       }
{*******************************************************}

unit App.DB.Entity;

interface

uses
  System.Classes, System.SysUtils, System.Variants;

type
  TEntityAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const Name: string);

    property Name: string read FName write FName;
  end;

  TColumnAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const Name: string);

    property Name: string read FName write FName;
  end;

  TIDAttribute = class(TCustomAttribute)
  end;

  TEntityClass = class of TEntity;

  TEntity = class(TPersistent)
  private
    FID: Variant;
  protected
  public
    constructor Create(); virtual;
    destructor Destroy(); override;

    class function EntityName(): string; virtual; abstract;
    class function FieldList(): string; virtual; abstract;
  published
    [TIDAttribute]
    [TColumnAttribute('ID')]
    property ID: Variant read FID write FID;
  end;

implementation

{ TEntityAttribute }

constructor TEntityAttribute.Create(const Name: string);
begin
  inherited Create();

  FName := Name;
end;

{ TColumnAttribute }

constructor TColumnAttribute.Create(const Name: string);
begin
  inherited Create();

  FName := Name;
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

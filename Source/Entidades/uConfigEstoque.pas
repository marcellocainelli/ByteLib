unit uConfigEstoque;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TConfigEstoque = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TConfigEstoque }

constructor TConfigEstoque.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select ce.*, 0 as INDICE from config_estoque ce where ce.id = 1');

  InicializaDataSource;
end;

destructor TConfigEstoque.Destroy;
begin

  inherited;
end;

class function TConfigEstoque.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConfigEstoque.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConfigEstoque.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConfigEstoque.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConfigEstoque.ModificaDisplayCampos;
begin

end;

function TConfigEstoque.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

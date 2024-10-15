unit uProdutoLoteEntrada;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TProdutoLoteEntrada = class(TInterfacedObject, iEntidade)
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

{ TProdutoLoteEntrada }

constructor TProdutoLoteEntrada.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select EFLE.*, EFL.LOTE, EFL.COMPLEMENTO, EFL.VALIDADE ' +
    'from ESTFILIAL_LOTE_ENTRADA EFLE ' +
    'Join ESTOQUEFILIAL_LOTE EFL on (EFL.ID = EFLE.ID_ESTOQUEFILIAL_LOTE) ' +
    'where SEQ_ESTOQUE = :pSeqEstoque');
  InicializaDataSource;
end;

destructor TProdutoLoteEntrada.Destroy;
begin
  inherited;
end;

class function TProdutoLoteEntrada.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoLoteEntrada.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoLoteEntrada.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'LOTE', False);
  FEntidadeBase.SetReadOnly(Value, 'COMPLEMENTO', False);
  FEntidadeBase.SetReadOnly(Value, 'VALIDADE', False);
end;

function TProdutoLoteEntrada.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From ESTFILIAL_LOTE_ENTRADA Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoLoteEntrada.ModificaDisplayCampos;
begin

end;

function TProdutoLoteEntrada.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

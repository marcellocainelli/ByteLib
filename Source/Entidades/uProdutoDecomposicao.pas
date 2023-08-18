unit uProdutoDecomposicao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, DIALOGS;
Type
  TProdutoDecomposicao = class(TInterfacedObject, iEntidade)
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

{ TProdutoDecomposicao }

constructor TProdutoDecomposicao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select PD.*, P.NOME_PROD, P.UNIDADE ' +
    'From PRODUTOS_DECOMPOSICAO PD ' +
    'Join PRODUTOS P On (P.COD_PROD = PD.COD_COMPONENTE) ' +
    'Where PD.COD_PRODUTO = :pCod_Prod');

  InicializaDataSource;
end;

destructor TProdutoDecomposicao.Destroy;
begin
  inherited;
end;

class function TProdutoDecomposicao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutoDecomposicao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutoDecomposicao.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
  Value.DataSet.Open;
end;

function TProdutoDecomposicao.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.AddParametro('pCOD_PROD', -1);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoDecomposicao.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.0000';
//  TCurrencyField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_CUST')).currency:= True;
end;

function TProdutoDecomposicao.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

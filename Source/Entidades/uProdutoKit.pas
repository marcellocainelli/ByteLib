unit uProdutoKit;
interface
uses
  Model.Entidade.Interfaces, Data.DB, sysutils, dialogs;
Type
  TProdutoKit = class(TInterfacedObject, iEntidade)
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
{ TProdutoKit }
constructor TProdutoKit.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select k.*, p.nome_prod, p.unidade, p.preco_cust, iif(k.flg_prc_venda_kit = ''S'', k.prc_venda_kit, p.preco_vend) as preco_vend ' +
    'from produtos_kit k ' +
    'join produtos p on (p.cod_prod = k.cod_componente) ' +
    'where k.cod_produto = :pcod_prod ');
  InicializaDataSource;
end;
destructor TProdutoKit.Destroy;
begin
  inherited;
end;
class function TProdutoKit.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TProdutoKit.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TProdutoKit.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and k.status = ''A'' ';
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, 'VALOR', ftCurrency);
  ModificaDisplayCampos;
  Value.DataSet.Open;
end;

function TProdutoKit.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pCod_Prod', '-1', ftString);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoKit.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.0000';
  TCurrencyField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_CUST')).currency:= True;
  TCurrencyField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
  TCurrencyField(FEntidadeBase.Iquery.Dataset.FieldByName('PRC_VENDA_KIT')).currency:= True;
end;
function TProdutoKit.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

unit uProdutoKit;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

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
    'Select K.*, P.NOME_PROD, P.UNIDADE, P.PRECO_CUST ' +
    'From PRODUTOS_KIT K ' +
    'Join PRODUTOS P On (P.COD_PROD = K.COD_COMPONENTE) ' +
    'Where K.COD_PRODUTO = :pCod_Prod');

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
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
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

  FEntidadeBase.AddParametro('pCod_Prod', -1, ftInteger);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProdutoKit.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.0000';
  TCurrencyField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_CUST')).currency:= True;
end;

function TProdutoKit.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

unit uOrcamentoItens;

interface

uses
  Model.Entidade.Interfaces, Model.Conexao.Interfaces, Data.DB, System.SysUtils;

Type
  TOrcamentoItens = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure GetText(Sender: TField; var Text: String; DisplayText: Boolean);
      procedure MyCalcFields(sender: TDataSet);
    public
      constructor Create(AConn: iConexao = nil);
      destructor Destroy; override;
      class function New(AConn: iConexao = nil): iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
      procedure SelecionaSQLConsulta;
  end;

implementation

uses
  uEntidadeBase;

{ TOrcamento }

constructor TOrcamentoItens.Create(AConn: iConexao);
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self, AConn);
  FEntidadeBase.TextoSQL(
    'select oi.*, p.preco_cust, p.peso, p.flg_grade, p.flg_lote, p.preco_vend as preco_tabela ' +
    'from pedido oi ' +
    'join produtos p on (p.cod_prod = oi.cod_prod) ');
  InicializaDataSource;
end;

destructor TOrcamentoItens.Destroy;
begin
  inherited;
end;

class function TOrcamentoItens.New(AConn: iConexao): iEntidade;
begin
  Result:= Self.Create(AConn);
end;

function TOrcamentoItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

procedure TOrcamentoItens.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin
  Text:= EmptyStr;
end;

function TOrcamentoItens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL;
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where NR_PEDIDO = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NR_PEDIDO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['VrVista', 'VrPrazo', 'VrCusto', 'Entregou'], [ftCurrency, ftCurrency, ftCurrency, ftFloat]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'PRECO_CUST', False);
  FEntidadeBase.SetReadOnly(Value, 'PESO', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_LOTE', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_GRADE', False);
  FEntidadeBase.SetReadOnly(Value, 'PRECO_TABELA', False);
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TOrcamentoItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NR_PEDIDO');
  FEntidadeBase.Iquery.SQL('Select * from pedido Where (1 <> 1)');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrcamentoItens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VrVista')).currency:= True;
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('FLG_ENTREGA')).OnGetText:= GetText;
end;

procedure TOrcamentoItens.MyCalcFields(sender: TDataSet);
begin
  FEntidadeBase.Iquery.DataSet.FieldByName('VrCusto').AsCurrency:= FEntidadeBase.Iquery.DataSet.FieldByName('QUANTIDADE').AsFloat * FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_CUST').AsCurrency;
  FEntidadeBase.Iquery.DataSet.FieldByName('VrVista').AsCurrency:= FEntidadeBase.Iquery.DataSet.FieldByName('QUANTIDADE').AsFloat * FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_VEND').AsCurrency;
  FEntidadeBase.Iquery.DataSet.FieldByName('VrPrazo').AsCurrency:= FEntidadeBase.Iquery.DataSet.FieldByName('QUANTIDADE').AsFloat * FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_PRAZ').AsCurrency;
end;

function TOrcamentoItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TOrcamentoItens.SelecionaSQLConsulta;
begin

end;

end.

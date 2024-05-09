unit uVendaItens;
interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils;
Type
  TVendaItens = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure GetText(Sender: TField; var Text: String; DisplayText: Boolean);
      procedure MyCalcFields(sender: TDataSet);
      procedure OnNewRecord(DataSet: TDataSet);
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
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
{ TVendaItens }
constructor TVendaItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;
destructor TVendaItens.Destroy;
begin
  inherited;
end;
class function TVendaItens.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TVendaItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
procedure TVendaItens.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin
  Text:= EmptyStr;
end;

function TVendaItens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where NUM_OPER = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NUM_OPER');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['VrVenda', 'VrCusto', 'VrDesconto', 'Id_ItemPedido','Dv_Seq_Venda','Possui_adicionais'], [ftCurrency, ftCurrency, ftCurrency, ftInteger, ftInteger, ftBoolean]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'PESO', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_LOTE', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_GRADE', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_SERIAL', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_MLFULL', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_PACOTE_SERVICOS', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_LOCACAO_EQUIPAMENTOS', False);
  FEntidadeBase.CalcFields(MyCalcFields);
end;
function TVendaItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('NUM_OPER');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where NUM_OPER = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TVendaItens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VrVenda')).currency:= True;
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('FLG_ENTREGA')).OnGetText:= GetText;
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('FLG_VALETROCA')).OnGetText:= GetText;
end;
procedure TVendaItens.MyCalcFields(sender: TDataSet);
begin
  FEntidadeBase.Iquery.DataSet.FieldByName('VrVenda').AsCurrency:= FEntidadeBase.Iquery.DataSet.FieldByName('QUANTIDADE').AsFloat * FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_VEND').AsCurrency;
  FEntidadeBase.Iquery.DataSet.FieldByName('VrCusto').AsCurrency:= FEntidadeBase.Iquery.DataSet.FieldByName('QUANTIDADE').AsFloat * FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_CUST').AsCurrency;
  FEntidadeBase.Iquery.DataSet.FieldByName('VrDesconto').AsCurrency:= FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_TAB').AsCurrency - FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_VEND').AsCurrency;
end;
procedure TVendaItens.OnNewRecord(DataSet: TDataSet);
begin
{$IFNDEF APP}
  FEntidadeBase.Iquery.DataSet.FieldByName('FLG_VENDA_MLFULL').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLG_VALETROCA').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLG_PACOTE_SERVICOS').AsString:= 'N';
{$ENDIF}
end;
function TVendaItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
procedure TVendaItens.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'Select V.*, P.PESO, P.FLG_LOTE, P.FLG_GRADE, P.SERIAL as FLG_SERIAL, P.FLG_MLFULL, P.FLG_PACOTE_SERVICOS, P.FLG_LOCACAO_EQUIPAMENTOS ' +
    'From VENDA V ' +
    'Inner Join PRODUTOS P On (P.COD_PROD = V.COD_PROD) ');
end;
end.

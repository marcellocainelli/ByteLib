unit uEstoque;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;
Type
  TEstoque = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure GetText(Sender: TField; var Text: String; DisplayText: Boolean);
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

{ TEstoque }

constructor TEstoque.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TEstoque.Destroy;
begin
  inherited;
end;

class function TEstoque.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoque.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoque.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where E.SEQ_MESTRE = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['VrCusto','MargemCalculada'], [ftCurrency, ftFloat]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'NOME_PROD', False);
  FEntidadeBase.SetReadOnly(Value, 'COD_MARCA', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_LOTE', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_GRADE', False);
  FEntidadeBase.SetReadOnly(Value, 'MARGEM', False);
  FEntidadeBase.SetReadOnly(Value, 'SERIAL', False);
  FEntidadeBase.SetReadOnly(Value, 'DECOMPOSICAO_PORC_PERDA', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_NAOPERMITE_ALTERAR_PRECO', False);
end;

function TEstoque.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where E.SEQ_MESTRE = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoque.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECOCOMPRA')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('DESCONTO')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('CUSTO_ENT')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VENDA_ENT')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VENDA_PRAZ')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANT_ENT')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VrCusto')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IPI')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FRETE')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FINANCEIRO')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('SUBSTITUICAO')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ICMSNFENTRADA')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ICMS_DIFERENCA')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('TXDIFERENCAICMS')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('MARGEMCALCULADA')).DisplayFormat:= '#,0.000';
end;

procedure TEstoque.OnNewRecord(DataSet: TDataSet);
begin
{$IFNDEF APP}
{$ENDIF}
end;

function TEstoque.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEstoque.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin

end;

procedure TEstoque.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'Select E.*, P.NOME_PROD, P.COD_MARCA, P.FLG_LOTE, FLG_GRADE, P.MARGEM, P.SERIAL, P.DECOMPOSICAO_PORC_PERDA, P.FLG_NAOPERMITE_ALTERAR_PRECO ' +
    'From ESTOQUE E ' +
    'Join PRODUTOS P on (P.COD_PROD = E.COD_PROD) ');
end;

end.

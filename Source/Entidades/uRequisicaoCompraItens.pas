unit uRequisicaoCompraItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Dialogs;

Type
  TRequisicaoCompraItens = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure MyCalcFields(sender: TDataSet);
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

{ TRequisicaoCompraItens }

constructor TRequisicaoCompraItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select RCI.*, P.NOME_PROD, P.QUANT_MIN, P.QUANT_MAX, P.UNIDADE, P.PRECOCOMPRA, P.IPI, ' +
    'P.FRETE, P.FINANCEIRO, P.SUBSTITUICAO, P.MARGEM, P.QTD_EMBALAGEM_COMPRA, P.C_MEDIO, ' +
    'P.PRECO_VEND, P.REFERENCIA, P.FLG_GRADE, P.DTULTIMAVENDA, EF.QUANTIDADE as ESTOQUE ' +
    'from REQUISICAO_COMPRA_ITENS RCI ' +
    'Join PRODUTOS P On (P.COD_PROD = RCI.COD_PROD) ' +
    'Left Join ESTOQUEFILIAL EF on (EF.COD_PROD = P.COD_PROD and EF.COD_FILIAL = :mCodFilial) ');
  InicializaDataSource;
end;

destructor TRequisicaoCompraItens.Destroy;
begin
  inherited;
end;

class function TRequisicaoCompraItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TRequisicaoCompraItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TRequisicaoCompraItens.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where RCI.ID_REQUISICAO_COMPRA = :IdRqCompra');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['VrCusto'], [ftCurrency]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'NOME_PROD', False);
  FEntidadeBase.SetReadOnly(Value, 'QUANT_MIN', False);
  FEntidadeBase.SetReadOnly(Value, 'QUANT_MAX', False);
  FEntidadeBase.SetReadOnly(Value, 'UNIDADE', False);
  FEntidadeBase.SetReadOnly(Value, 'PRECOCOMPRA', False);
  FEntidadeBase.SetReadOnly(Value, 'IPI', False);
  FEntidadeBase.SetReadOnly(Value, 'FRETE', False);
  FEntidadeBase.SetReadOnly(Value, 'FINANCEIRO', False);
  FEntidadeBase.SetReadOnly(Value, 'SUBSTITUICAO', False);
  FEntidadeBase.SetReadOnly(Value, 'MARGEM', False);
  FEntidadeBase.SetReadOnly(Value, 'QTD_EMBALAGEM_COMPRA', False);
  FEntidadeBase.SetReadOnly(Value, 'C_MEDIO', False);
  FEntidadeBase.SetReadOnly(Value, 'PRECO_VEND', False);
  FEntidadeBase.SetReadOnly(Value, 'REFERENCIA', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_GRADE', False);
  FEntidadeBase.SetReadOnly(Value, 'DTULTIMAVENDA', False);
  FEntidadeBase.SetReadOnly(Value, 'ESTOQUE', False);
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TRequisicaoCompraItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TRequisicaoCompraItens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_CUSTO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANT_MIN')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANT_MAX')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECOCOMPRA')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IPI')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FRETE')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FINANCEIRO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('SUBSTITUICAO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('MARGEM')).DisplayFormat:= '#,0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QTD_EMBALAGEM_COMPRA')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('C_MEDIO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ESTOQUE')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
end;

procedure TRequisicaoCompraItens.MyCalcFields(sender: TDataSet);
begin
  FEntidadeBase.Iquery.DataSet.FieldByName('VrCusto').AsCurrency:= FEntidadeBase.Iquery.DataSet.FieldByName('QUANTIDADE').AsFloat * FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_CUSTO').AsCurrency;
end;

function TRequisicaoCompraItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

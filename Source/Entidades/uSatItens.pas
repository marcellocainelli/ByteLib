unit uSatItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;

Type
  TSatItens = class(TInterfacedObject, iEntidade)
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

{ TSatItens }

constructor TSatItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TipoPesquisa(0);
  FEntidadeBase.TextoSQL(
    'Select SI.*, P.CLASFISCAL, P.ICMS as CODICMS, ' +
    'P.COD_BARRA, P.UNIDADE, P.COD_ANP, P.COMPLEMENTO, P.CEST, ' +
    'P.PRECO_VEND as PRECO_TABELA ' +
    'From SAT_ITENS SI ' +
    'Join PRODUTOS P On (P.COD_PROD = SI.COD_PROD) ' +
    'Where (1 = 1) ');
  InicializaDataSource;
end;

destructor TSatItens.Destroy;
begin
  inherited;
end;

class function TSatItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TSatItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TSatItens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSql + 'and si.ID_SAT_MVTO = :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NUMEROITEM');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['VrCalculado', 'preco_liquido'], [ftCurrency, ftCurrency]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'CLASFISCAL', False);
  FEntidadeBase.SetReadOnly(Value, 'CODICMS', False);
  FEntidadeBase.SetReadOnly(Value, 'COD_BARRA', False);
  FEntidadeBase.SetReadOnly(Value, 'UNIDADE', False);
  FEntidadeBase.SetReadOnly(Value, 'COD_ANP', False);
  FEntidadeBase.SetReadOnly(Value, 'COMPLEMENTO', False);
  FEntidadeBase.SetReadOnly(Value, 'CEST', False);
  FEntidadeBase.SetReadOnly(Value, 'PRECO_TABELA', False);
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TSatItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NUMEROITEM');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + 'and  si.ID_SAT_MVTO = :Parametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TSatItens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).DisplayFormat:= '###,##0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VRDESCONTO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VROUTROS')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VRICMS')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PIS_VALOR')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('COFINS_VALOR')).currency:= True;
end;

procedure TSatItens.MyCalcFields(sender: TDataSet);
begin
  FEntidadeBase.Iquery.DataSet.FieldByName('VrCalculado').AsCurrency:=
    TLib.RoundABNT(FEntidadeBase.Iquery.DataSet.FieldByName('QUANTIDADE').AsFloat * FEntidadeBase.Iquery.DataSet.FieldByName('PRECO_VEND').AsCurrency,-2);
end;

function TSatItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

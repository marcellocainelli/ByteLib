unit uEstoqueMestre;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;
Type
  TEstoqueMestre = class(TInterfacedObject, iEntidade)
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

{ TEstoqueMestre }

constructor TEstoqueMestre.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TEstoqueMestre.Destroy;
begin
  inherited;
end;

class function TEstoqueMestre.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueMestre.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueMestre.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where SEQ = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TEstoqueMestre.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where SEQ = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoqueMestre.ModificaDisplayCampos;
begin
//  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('CUSTO_ENT')).currency:= True;
//  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VENDA_ENT')).currency:= True;
//  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANT_ENT')).DisplayFormat:= '#,0.000';
//  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VrCusto')).currency:= True;
end;

procedure TEstoqueMestre.MyCalcFields(sender: TDataSet);
begin

end;

function TEstoqueMestre.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEstoqueMestre.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin

end;

procedure TEstoqueMestre.OnNewRecord(DataSet: TDataSet);
begin
{$IFNDEF APP}
{$ENDIF}
end;

procedure TEstoqueMestre.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL('Select * from ESTOQUEMESTRE ');
end;

end.

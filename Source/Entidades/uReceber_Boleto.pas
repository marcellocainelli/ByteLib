unit uReceber_Boleto;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils;

Type
  TReceber_Boleto = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
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

{ TBoleto }

constructor TReceber_Boleto.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TReceber_Boleto.Destroy;
begin
  inherited;
end;

class function TReceber_Boleto.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TReceber_Boleto.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TReceber_Boleto.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' and NUM_OPER = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TReceber_Boleto.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' and NUM_OPER = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TReceber_Boleto.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
end;

procedure TReceber_Boleto.MyCalcFields(sender: TDataSet);
begin

end;

procedure TReceber_Boleto.OnNewRecord(DataSet: TDataSet);
begin
{$IFNDEF APP}
  FEntidadeBase.Iquery.DataSet.FieldByName('situacao').AsString:= 'A';
  FEntidadeBase.Iquery.DataSet.FieldByName('cbr_email_enviado').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('banco_conta').AsString:= 'CAIXA';
  FEntidadeBase.Iquery.DataSet.FieldByName('cbr_whatsapp_enviado').AsString:= 'N';
{$ENDIF}
end;

function TReceber_Boleto.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TReceber_Boleto.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL('select * from receber where situacao = ''A'' ');
end;

end.

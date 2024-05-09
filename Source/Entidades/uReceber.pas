unit uReceber;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Dialogs;

Type
  TReceber = class(TInterfacedObject, iEntidade)
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
  end;

implementation

uses
  uEntidadeBase;

{ TReceber }

constructor TReceber.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select r.*, case when r.valor < 0 then ''DV'' else ''VD'' end as Tipo from receber r where r.situacao = ''A'' ');
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TReceber.Destroy;
begin
  inherited;
end;

class function TReceber.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TReceber.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TReceber.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSQL + ' and r.NUM_OPER = :pParametro';
    1: vTextoSQL:= vTextoSQL + ' and r.COD_CLI  = :pParametro and r.BAIXADO = ''X'' and r.COD_FILIAL = :pCodFilial';
    2: vTextoSQL:= vTextoSQL + ' and r.COD_CLI  = :pParametro and r.BAIXADO = ''X'' and r.COD_FILIAL = :pCodFilial and r.vencimento between :pDt_ini and :pDt_Fim ';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['Marcado'], [ftBoolean]);
  ModificaDisplayCampos;
  FEntidadeBase.Iquery.IndexFieldNames('TIPO; VENCIMENTO; DT_VENDA');
  Value.DataSet.Open;
end;

function TReceber.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' and r.NUM_OPER = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TReceber.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
end;

procedure TReceber.MyCalcFields(sender: TDataSet);
begin
//  If (sender.FieldByName('VALOR').AsCurrency < 0) then
//    sender.FieldByName('Tipo').AsString:= 'DV'
//  else
//    sender.FieldByName('Tipo').AsString:= 'VD';
end;

procedure TReceber.OnNewRecord(DataSet: TDataSet);
begin
{$IFNDEF APP}
  FEntidadeBase.Iquery.DataSet.FieldByName('situacao').AsString:= 'A';
  FEntidadeBase.Iquery.DataSet.FieldByName('cbr_email_enviado').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('banco_conta').AsString:= 'CAIXA';
  FEntidadeBase.Iquery.DataSet.FieldByName('cbr_whatsapp_enviado').AsString:= 'N';
{$ENDIF}
end;

function TReceber.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

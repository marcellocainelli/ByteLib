unit uEmpenho_Itens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;

Type
  TEmpenho_Itens = class(TInterfacedObject, iEntidade)
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

{ TEmpenho_Itens }

constructor TEmpenho_Itens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TEmpenho_Itens.Destroy;
begin
  inherited;
end;

class function TEmpenho_Itens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEmpenho_Itens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

procedure TEmpenho_Itens.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin
  Text:= EmptyStr;
end;

function TEmpenho_Itens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where IP.NUM_OPER = :pParametro ';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['Entregou'], [ftFloat]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'UNIDADE', False);
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TEmpenho_Itens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where IP.NUM_OPER = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEmpenho_Itens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('TOTAL_ENTR')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FALTA_ENTR')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('Entregou')).DisplayFormat:= '#,0.000';
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('BAIXA_EST')).OnGetText:= GetText;
end;

function TEmpenho_Itens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEmpenho_Itens.MyCalcFields(sender: TDataSet);
begin

end;

procedure TEmpenho_Itens.OnNewRecord(DataSet: TDataSet);
begin

end;

procedure TEmpenho_Itens.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'select IP.*, P.UNIDADE ' +
    'from ITENSPENDENCIA IP ' +
    'JOIN PRODUTOS P ON(P.COD_PROD = IP.COD_PROD) ');
end;

end.

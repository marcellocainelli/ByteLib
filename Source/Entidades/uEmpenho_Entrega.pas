unit uEmpenho_Entrega;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;

Type
  TEmpenho_Entrega = class(TInterfacedObject, iEntidade)
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

{ TEmpenho_Entrega }

constructor TEmpenho_Entrega.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TEmpenho_Entrega.Destroy;
begin
  inherited;
end;

class function TEmpenho_Entrega.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEmpenho_Entrega.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEmpenho_Entrega.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where PE.NUM_OPER = :pParametro ';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'COD_CLI', False);
  FEntidadeBase.SetReadOnly(Value, 'NOME_CLI', False);
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TEmpenho_Entrega.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where PE.NUM_OPER = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEmpenho_Entrega.ModificaDisplayCampos;
begin

end;

function TEmpenho_Entrega.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEmpenho_Entrega.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin
  Text:= EmptyStr;
end;

procedure TEmpenho_Entrega.MyCalcFields(sender: TDataSet);
begin

end;

procedure TEmpenho_Entrega.OnNewRecord(DataSet: TDataSet);
begin

end;

procedure TEmpenho_Entrega.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'Select PE.*, P.COD_CLI, P.NOME_CLI ' +
    'From PENDENCIA_ENTREGA PE ' +
    'Join PENDENCIA P On (P.NUM_OPER = PE.NUM_OPER) ');
end;

end.

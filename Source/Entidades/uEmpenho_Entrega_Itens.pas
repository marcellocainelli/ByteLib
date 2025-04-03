unit uEmpenho_Entrega_Itens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;

Type
  TEmpenhoEntrega_Itens = class(TInterfacedObject, iEntidade)
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

constructor TEmpenhoEntrega_Itens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TEmpenhoEntrega_Itens.Destroy;
begin
  inherited;
end;

class function TEmpenhoEntrega_Itens.New: iEntidade;
begin
  Result:= Self.Create;
end;


function TEmpenhoEntrega_Itens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

procedure TEmpenhoEntrega_Itens.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin

end;

function TEmpenhoEntrega_Itens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where PI.SEQ_ENTREGA = :pParametro ';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'UNIDADE', False);
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TEmpenhoEntrega_Itens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where PI.SEQ_ENTREGA = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEmpenhoEntrega_Itens.ModificaDisplayCampos;
begin

end;

function TEmpenhoEntrega_Itens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEmpenhoEntrega_Itens.MyCalcFields(sender: TDataSet);
begin

end;

procedure TEmpenhoEntrega_Itens.OnNewRecord(DataSet: TDataSet);
begin

end;

procedure TEmpenhoEntrega_Itens.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'Select PI.*, P.UNIDADE ' +
    'From PENDENCIA_ENTREGA_ITENS PI ' +
    'Left Join PRODUTOS P On (P.COD_PROD = PI.COD_PROD) ');
end;

end.

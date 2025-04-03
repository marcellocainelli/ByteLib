unit uEmpenho;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;

Type
  TEmpenho = class(TInterfacedObject, iEntidade)
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

{ TEmpenho }

constructor TEmpenho.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TEmpenho.Destroy;
begin
  inherited;
end;

class function TEmpenho.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEmpenho.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

procedure TEmpenho.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin

end;

function TEmpenho.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where NUM_OPER = :pParametro ';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  //FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  //FEntidadeBase.CriaCampo(Value, ['VrVenda', 'VrCusto', 'VrDesconto', 'Id_ItemPedido','Dv_Seq_Venda','Possui_adicionais','Marcado'], [ftCurrency, ftCurrency, ftCurrency, ftInteger, ftInteger, ftBoolean, ftBoolean]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TEmpenho.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  //FEntidadeBase.Iquery.IndexFieldNames('SEQ');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where NUM_OPER = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEmpenho.ModificaDisplayCampos;
begin

end;

function TEmpenho.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEmpenho.MyCalcFields(sender: TDataSet);
begin

end;

procedure TEmpenho.OnNewRecord(DataSet: TDataSet);
begin

end;

procedure TEmpenho.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL('Select * from PENDENCIA ');
end;

end.

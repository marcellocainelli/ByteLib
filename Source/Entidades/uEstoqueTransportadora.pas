unit uEstoqueTransportadora;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils, Byte.Lib;
Type
  TEstoqueTransportadora = class(TInterfacedObject, iEntidade)
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

{ TEstoqueTransportadora }

constructor TEstoqueTransportadora.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TEstoqueTransportadora.Destroy;
begin
  inherited;
end;

class function TEstoqueTransportadora.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstoqueTransportadora.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstoqueTransportadora.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where SEQ_ESTOQUEMESTRE = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('SEQ_ESTOQUEMESTRE');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.CalcFields(MyCalcFields);
end;

function TEstoqueTransportadora.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('SEQ_ESTOQUEMESTRE');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where SEQ_ESTOQUEMESTRE = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TEstoqueTransportadora.GetText(Sender: TField; var Text: String; DisplayText: Boolean);
begin

end;

procedure TEstoqueTransportadora.ModificaDisplayCampos;
begin

end;

procedure TEstoqueTransportadora.MyCalcFields(sender: TDataSet);
begin

end;

procedure TEstoqueTransportadora.OnNewRecord(DataSet: TDataSet);
begin

end;

function TEstoqueTransportadora.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEstoqueTransportadora.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'Select ET.*, T.NOME, T.CNPJ, T.IE, T.UF ' +
    'From ESTOQUE_TRANSPORTADORA ET ' +
    'Join TRANSPORTADORA T On (T.CODIGO = ET.COD_TRANSPORTADORA) ');
end;

end.

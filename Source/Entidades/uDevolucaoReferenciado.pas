unit uDevolucaoReferenciado;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils;

Type
  TDevolucaoReferenciado = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
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

{ TDevolucaoReferenciado }

constructor TDevolucaoReferenciado.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TDevolucaoReferenciado.Destroy;
begin
  inherited;
end;

class function TDevolucaoReferenciado.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TDevolucaoReferenciado.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TDevolucaoReferenciado.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' where d.num_oper = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('id');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'cod_fornec', False);
  FEntidadeBase.SetReadOnly(Value, 'data', False);
  FEntidadeBase.SetReadOnly(Value, 'documento', False);
  FEntidadeBase.SetReadOnly(Value, 'nfechave', False);
  FEntidadeBase.SetReadOnly(Value, 'valortotalnota', False);
end;

function TDevolucaoReferenciado.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('id');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where d.num_oper = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TDevolucaoReferenciado.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('valortotalnota')).currency:= True;
end;

procedure TDevolucaoReferenciado.OnNewRecord(DataSet: TDataSet);
begin

end;

function TDevolucaoReferenciado.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TDevolucaoReferenciado.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'select d.id, d.num_oper, d.seq_mestre, em.cod_fornec, em.data, em.documento, em.nfechave, em.valortotalnota ' +
    'from devolucao_docreferenciado d ' +
    'join estoquemestre em on (em.seq = d.seq_mestre) ');
end;

end.

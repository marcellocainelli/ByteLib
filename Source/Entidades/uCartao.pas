unit uCartao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils;

Type
  TCartao = class(TInterfacedObject, iEntidade)
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

{ TCartao }

constructor TCartao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TCartao.Destroy;
begin
  inherited;
end;

class function TCartao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCartao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCartao.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where c.num_oper = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('cod_operadora; vencimento');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'operadora', False);
  FEntidadeBase.SetReadOnly(Value, 'tipo_operacao', False);
  FEntidadeBase.SetReadOnly(Value, 'flg_gera_transferencia_banco', False);
  FEntidadeBase.SetReadOnly(Value, 'flg_nao_gera_cashback', False);
end;

function TCartao.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('cod_operadora; vencimento');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where c.num_oper = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TCartao.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
end;

procedure TCartao.OnNewRecord(DataSet: TDataSet);
begin
//  FEntidadeBase.Iquery.DataSet.FieldByName('SITUACAO').AsString:= 'A';
end;

function TCartao.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TCartao.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'select c.*, o.nome as operadora, o.tipo_operacao, o.flg_gera_transferencia_banco, o.flg_nao_gera_cashback ' +
    ' from cartao c join operadora o on (o.codigo = c.cod_operadora)');
end;

end.

unit uOrcamento;

interface

uses
  Model.Entidade.Interfaces, Model.Conexao.Interfaces, Data.DB, System.SysUtils,
  StrUtils;

Type
  TOrcamento = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create(AConn: iConexao = nil);
      destructor Destroy; override;
      class function New(AConn: iConexao = nil): iEntidade;
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

{ TOrcamento }

constructor TOrcamento.Create(AConn: iConexao);
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self, AConn);
  InicializaDataSource;
end;

destructor TOrcamento.Destroy;
begin
  inherited;
end;

class function TOrcamento.New(AConn: iConexao): iEntidade;
begin
  Result:= Self.Create(AConn);
end;

function TOrcamento.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrcamento.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL;
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' and o.NR_PEDIDO = :pParametro ';
  end;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and o.situacao = ''A'' ';
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME_CLI');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrcamento.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NR_PEDIDO');
  FEntidadeBase.Iquery.SQL('Select * from orc_pend Where (1 <> 1)');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrcamento.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
end;

function TOrcamento.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TOrcamento.SelecionaSQLConsulta;
begin
  case AnsiIndexStr(FEntidadeBase.TipoConsulta, ['Consulta', 'Cadastro']) of
  0: FEntidadeBase.TextoSQL(
    'select o.nr_pedido, o.nome_cli, o.dt_pedido, o.hora, o.cod_cli, o.valor, o.observacao, o.localentrega, o.ecommerce_id_pedido, o.num_ficha, f.nome ' +
    'from orc_pend o ' +
    'join funci f on (f.codigo = o.cod_fun) ' +
    'where o.baixado = ''X'' and o.tipo  = ''P'' and o.cod_filial = :pCodFilial ');
  1: FEntidadeBase.TextoSQL('Select o.* from orc_pend o where (1 = 1)' );
  end;
end;

end.

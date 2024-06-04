unit uOrdemClienteEquipamentoLocal;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TOrdCliEqptoLocal = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
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

{ TVendaItens }

constructor TOrdCliEqptoLocal.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select ocel.*, oe.descricao as equipamento, ol.descricao as local ' +
    'from ord_cli_equipamento_local ocel ' +
    'join ord_equipamentos oe on (oe.codigo = ocel.cod_equipamento) ' +
    'left join ord_local ol on (ol.codigo = ocel.cod_local) ');
  InicializaDataSource;
end;

destructor TOrdCliEqptoLocal.Destroy;
begin
  inherited;
end;

class function TOrdCliEqptoLocal.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdCliEqptoLocal.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdCliEqptoLocal.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSQL + ' Where ocel.cod_cliente = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('equipamento');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'equipamento', False);
  FEntidadeBase.SetReadOnly(Value, 'local', False);
end;

function TOrdCliEqptoLocal.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('equipamento');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where ocel.cod_cliente = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrdCliEqptoLocal.ModificaDisplayCampos;
begin

end;

function TOrdCliEqptoLocal.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

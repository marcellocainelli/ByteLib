unit uAgendaServico;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TAgendaServico = class(TInterfacedObject, iEntidade)
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

{ TAgendaServico }

constructor TAgendaServico.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select pag.*, c.nome as cliente, p.nome_prod as descricao ' +
    'from agendaservico pag ' +
    'join cadcli c on (c.codigo = pag.cod_cliente) ' +
    'join produtos p on (p.cod_prod = pag.cod_produto) ' +
    'where pag.data between :pDt_Inicio and :pDt_Fim ');
  InicializaDataSource;
end;

destructor TAgendaServico.Destroy;
begin
  inherited;
end;

class function TAgendaServico.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TAgendaServico.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TAgendaServico.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSql + ' and pag.cod_cliente = :pParametro ';
  end;
  vTextoSQL:= vTextoSQL + ' Order by pag.data, pag.hora_inicio';
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TAgendaServico.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:=
    'select pag.*, c.nome as cliente, p.nome_prod as descricao ' +
    'from agendaservico pag ' +
    'join cadcli c on (c.codigo = pag.cod_cliente) ' +
    'join produtos p on (p.cod_prod = pag.cod_produto) ' +
    'where 1 <> 1 ';
  FEntidadeBase.Iquery.IndexFieldNames('data');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TAgendaServico.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DATA')).EditMask:= '!99/99/00;1;_';
  TTimeField(FEntidadeBase.Iquery.Dataset.FieldByName('HORA_INICIO')).EditMask:= '!99:99;1;_';
  TTimeField(FEntidadeBase.Iquery.Dataset.FieldByName('HORA_FINAL')).EditMask:= '!99:99;1;_';
end;

function TAgendaServico.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

unit uAgendaGruposUsuarios;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TAgendaGruposUsuarios = class(TInterfacedObject, iEntidade)
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

{ TAgendaGruposUsuarios }

constructor TAgendaGruposUsuarios.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select agu.*, ag.descricao, u.nome ' +
    'from agenda_grupos_usuarios agu ' +
    'join agenda_grupos ag on (ag.codigo = agu.agenda_grupos_codigo) ' +
    'join usuario u on (u.cod_caixa = agu.usuario_cod_caixa) ' +
    'where agu.agenda_grupos_codigo = :pAgenda_grupos_codigo');
  InicializaDataSource;
end;

destructor TAgendaGruposUsuarios.Destroy;
begin
  inherited;
end;

class function TAgendaGruposUsuarios.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TAgendaGruposUsuarios.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TAgendaGruposUsuarios.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('usuario_cod_caixa');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TAgendaGruposUsuarios.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From agenda_grupos_usuarios Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TAgendaGruposUsuarios.ModificaDisplayCampos;
begin

end;

function TAgendaGruposUsuarios.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

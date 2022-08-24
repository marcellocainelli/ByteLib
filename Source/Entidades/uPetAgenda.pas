unit uPetAgenda;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPetAgenda = class(TInterfacedObject, iEntidade)
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

{ TPetAgenda }

constructor TPetAgenda.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select pag.*, c.nome as cliente, pa.nome as animal, p.nome_prod as descricao ' +
    'from pet_agenda pag ' +
    'join cadcli c on (c.codigo = pag.cod_cliente) ' +
    'join pet_animais pa on (pa.codigo = pag.cod_animal) ' +
    'join produtos p on (p.cod_prod = pag.cod_produto) ' +
    'where pag.data between :pDt_Inicio and :pDt_Fim ');
  InicializaDataSource;
end;

destructor TPetAgenda.Destroy;
begin
  inherited;
end;

class function TPetAgenda.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPetAgenda.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPetAgenda.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSql + ' and pag.cod_cliente = :pParametro ';
    1: vTextoSQL:= vTextoSql + ' and pag.cod_animal = :pParametro ';
  end;
  vTextoSQL:= vTextoSQL + ' Order by pag.data, pag.hora_inicio';
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPetAgenda.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:=
    'select pag.*, c.nome as cliente, pa.nome as animal, p.nome_prod as descricao ' +
    'from pet_agenda pag ' +
    'join cadcli c on (c.codigo = pag.cod_cliente) ' +
    'join pet_animais pa on (pa.codigo = pag.cod_animal) ' +
    'join produtos p on (p.cod_prod = pag.cod_produto) ' +
    'where 1 <> 1 ';
  FEntidadeBase.Iquery.IndexFieldNames('data');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPetAgenda.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DATA')).EditMask:= '!99/99/00;1;_';
  TTimeField(FEntidadeBase.Iquery.Dataset.FieldByName('HORA_INICIO')).EditMask:= '!99:99;1;_';
  TTimeField(FEntidadeBase.Iquery.Dataset.FieldByName('HORA_FINAL')).EditMask:= '!99:99;1;_';
end;

function TPetAgenda.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

unit uPetVacinaAgenda;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPetVacinaAgenda = class(TInterfacedObject, iEntidade)
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

{ TPetVacinaAgenda }

constructor TPetVacinaAgenda.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select pva.*, c.nome as cliente, pa.nome as animal, pv.descricao ' +
    'from pet_vacina_agenda pva ' +
    'join cadcli c on (c.codigo = pva.cod_cliente) ' +
    'join pet_animais pa on (pa.codigo = pva.cod_animal) ' +
    'join pet_vacina pv on (pv.codigo = pva.cod_vacina) ' +
    'where (1 = 1) ');
  InicializaDataSource;
end;

destructor TPetVacinaAgenda.Destroy;
begin
  inherited;
end;

class function TPetVacinaAgenda.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPetVacinaAgenda.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPetVacinaAgenda.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSql + ' and pva.status = ''Pendente'' and pva.data between :pDt_Inicio and :pDt_Fim ';
    1: vTextoSQL:= vTextoSql + ' and pva.status = ''Pendente'' and pva.cod_animal = :pParametro ';
    2: vTextoSQL:= vTextoSql + ' and pva.cod_animal = :pParametro ';
    3: vTextoSQL:= vTextoSql + ' and pva.data between :pDt_Inicio and :pDt_Fim ';
    4: vTextoSQL:= vTextoSql + ' and pva.status = ''Pendente'' and pva.data between :pDt_Inicio and :pDt_Fim and pva.cod_cliente = :pCod_Cliente ';
    5: vTextoSQL:= vTextoSql + ' and pva.data between :pDt_Inicio and :pDt_Fim and pva.cod_cliente = :pCod_Cliente ';
  end;
  vTextoSQL:= vTextoSQL + ' Order by pva.data';
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPetVacinaAgenda.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:=
    'select pva.*, c.nome as cliente, pa.nome as animal, pv.descricao ' +
    'from pet_vacina_agenda pva ' +
    'join cadcli c on (c.codigo = pva.cod_cliente) ' +
    'join pet_animais pa on (pa.codigo = pva.cod_animal) ' +
    'join pet_vacina pv on (pv.codigo = pva.cod_vacina) ' +
    'where 1 <> 1 ';
  FEntidadeBase.Iquery.IndexFieldNames('data');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPetVacinaAgenda.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DATA')).EditMask:= '!99/99/00;1;_';
end;

function TPetVacinaAgenda.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

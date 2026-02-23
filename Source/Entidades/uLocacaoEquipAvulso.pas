unit uLocacaoEquipAvulso;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TLocacaoEquipAvulso = class(TInterfacedObject, iEntidade)
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
{ TLocacaoEquipAvulso }
constructor TLocacaoEquipAvulso.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select lea.*, c.nome from LOCACAO_EQUIP_AVULSO lea ' +
    'join cadcli c on (c.codigo = lea.cod_cli) ' +
    'where (1 = 1) '
  );
  InicializaDataSource;
end;
destructor TLocacaoEquipAvulso.Destroy;
begin
  inherited;
end;
class function TLocacaoEquipAvulso.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TLocacaoEquipAvulso.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TLocacaoEquipAvulso.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  if FEntidadeBase.TipoConsulta.Equals('Historico') then
    vTextoSQL:= FEntidadeBase.TextoSql + 'and lea.status <> :pStatus '
  else
    vTextoSQL:= FEntidadeBase.TextoSql + 'and lea.status = :pStatus ';
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + 'and NOME = :pNomeCliente';
    2: vTextoSQL:= vTextoSQL + 'and DT_FINAL >= :pData';
    3: vTextoSQL:= vTextoSQL;
    4: vTextoSQL:= vTextoSQL + 'and upper(EQUIP_DESCRICAO) containing upper(:pDescricao)';
    5: vTextoSQL:= vTextoSQL + 'and DT_INICIO >= :pDtInicio and DT_FINAL <= :pDtFinal';
  end;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TLocacaoEquipAvulso.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
end;
procedure TLocacaoEquipAvulso.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_inicio')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dt_final')).EditMask:= '!99/99/00;1;_';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
end;
function TLocacaoEquipAvulso.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

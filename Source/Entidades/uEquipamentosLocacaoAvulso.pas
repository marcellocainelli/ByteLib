unit uEquipamentosLocacaoAvulso;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TEquipamentosLocacaoAvulso = class(TInterfacedObject, iEntidade)
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
constructor TEquipamentosLocacaoAvulso.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select le.* ' +
    'from LOCACAO_EQUIPAMENTOS le ' +
    'where (1 = 1) '
  );
  InicializaDataSource;
end;
destructor TEquipamentosLocacaoAvulso.Destroy;
begin
  inherited;
end;
class function TEquipamentosLocacaoAvulso.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TEquipamentosLocacaoAvulso.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TEquipamentosLocacaoAvulso.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + 'and le.STATUS = :pStatus';
    2: vTextoSQL:= vTextoSQL + 'and (le.STATUS = ''A'' or le.STATUS = ''R'' or le.STATUS = ''P'')';
    3: vTextoSQL:= vTextoSQL + 'and le.ID = :pID';
  end;
  if FEntidadeBase.Inativos then
    vTextoSQL:= FEntidadeBase.TextoSQL + 'and le.status = ''I''';
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TEquipamentosLocacaoAvulso.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
end;
procedure TEquipamentosLocacaoAvulso.ModificaDisplayCampos;
begin

end;
function TEquipamentosLocacaoAvulso.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

unit uGrupoPromocao;

interface
uses
  System.SysUtils,
  Data.DB,
  Model.Entidade.Interfaces;
Type
  TGrupoPromocao = class(TInterfacedObject, iEntidade)
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
{ TGrupo }
constructor TGrupoPromocao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('SELECT * FROM GRUPO_PROMOCAO ');
  InicializaDataSource;
end;
destructor TGrupoPromocao.Destroy;
begin
  inherited;
end;
class function TGrupoPromocao.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TGrupoPromocao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TGrupoPromocao.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + 'where (current_date between dt_inicio and dt_fim) or (current_date < dt_inicio)'; //ativas e futuras
    2: vTextoSQL:= vTextoSQL + 'where current_date > dt_fim'; //inativas
  end;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TGrupoPromocao.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' where 1<>1 ';
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TGrupoPromocao.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_PROMO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE_MIN')).DisplayFormat:= '#,0.00';
end;
function TGrupoPromocao.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

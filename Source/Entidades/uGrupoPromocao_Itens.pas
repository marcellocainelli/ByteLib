unit uGrupoPromocao_Itens;

interface
uses
  System.SysUtils,
  Data.DB,
  Model.Entidade.Interfaces;
Type
  TGrupoPromocaoItem = class(TInterfacedObject, iEntidade)
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
constructor TGrupoPromocaoItem.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'SELECT gpi.*, gp.dt_inicio, gp.dt_fim, gp.preco_promo as grupo_preco, gp.flag_regra_grupo, gp.quantidade_min as grupo_qtdd, p.nome_prod, gp.descricao as promo_nome ' +
    'from GRUPO_PROMOCAO_ITEM gpi ' +
    'join produtos p on (p.cod_prod = gpi.cod_prod) ' +
    'join grupo_promocao gp on (gp.id = gpi.id_grupo_promo)'
  );
  InicializaDataSource;
end;
destructor TGrupoPromocaoItem.Destroy;
begin
  inherited;
end;
class function TGrupoPromocaoItem.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TGrupoPromocaoItem.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TGrupoPromocaoItem.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' where gpi.id_grupo_promo = :pIdGrupoPromo';
    2: vTextoSQL:= vTextoSQL + ' where gpi.id_grupo_promo = :pIdGrupoPromo and gpi.cod_prod = :pCodProd';
    3: vTextoSQL:= vTextoSQL + ' where gpi.cod_prod = :pCodProd';
    4: vTextoSQL:= vTextoSQL + ' where gpi.cod_prod = :pCodProd and gpi.id_grupo_promo <> :pIdGrupoPromo ' +
                               ' and gp.dt_fim >= :pDtInicio';
//    4: vTextoSQL:= vTextoSQL + ' where gpi.cod_prod = :pCodProd and gpi.id_grupo_promo <> :pIdGrupoPromo ' +
//                               ' and ((:pDtInicio between gp.dt_inicio and gp.dt_fim) or (:pDtFim between gp.dt_inicio and gp.dt_fim))';
  end;
//  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and current_date between gp.dt_inicio and gp.dt_fim';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TGrupoPromocaoItem.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' where 1<>1 ';
//  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TGrupoPromocaoItem.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_PROMO')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE_MIN')).DisplayFormat:= '#,0.00';
end;
function TGrupoPromocaoItem.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

unit uPagar;
interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TPagar = class(TInterfacedObject, iEntidade)
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
  uEntidadeBase, uDmFuncoes;
{ TPagar }
constructor TPagar.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select p.*, c.descricao ' +
    'From PAGAR p ' +
    'left join centrocusto c on (c.codigo = p.cod_centrocusto) ' +
    'Where p.baixado = :pBaixado and p.cod_filial = :pCodFilial');
  InicializaDataSource;
end;
destructor TPagar.Destroy;
begin
  inherited;
end;
class function TPagar.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TPagar.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPagar.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
  vIndice: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vIndice:= 'Vencimento';
  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    //busca por Contas a Pagar
    0: begin
      if FEntidadeBase.RegraPesquisa <> '30/12/99 30/12/99' then begin
        If Copy(FEntidadeBase.RegraPesquisa,1,8) = '30/12/99' then
          vTextoSQL:= vTextoSQL + ' and vencimento <= :pDtFim'
        else
          vTextoSQL:= vTextoSQL + ' and vencimento between :pDtInicio and :pDtFim';
      end;
    end;
    //busca por Contas Pagas
    1: begin
      if FEntidadeBase.RegraPesquisa <> '30/12/99 30/12/99' then begin
        If Copy(FEntidadeBase.RegraPesquisa,1,8) = '30/12/99' then
          vTextoSQL:= vTextoSQL + ' and dt_pgto <= :pDtFim'
        else
          vTextoSQL:= vTextoSQL + ' and dt_pgto between :pDtInicio and :pDtFim';
      end;
      vIndice:= 'Dt_Pgto';
    end;
    //busca por Contas a Pagar mesmo num_oper
    2: vTextoSQL:= vTextoSql + ' and NUM_OPER = :mNum_Oper';
    3: vTextoSQL:= vTextoSQL + ' and ' + FEntidadeBase.TextoPesquisa + ' ' + FEntidadeBase.RegraPesquisa + ':' + FEntidadeBase.TextoPesquisa;
  end;
  FEntidadeBase.Iquery.Dataset.FieldDefs.Clear;
  FEntidadeBase.Iquery.Dataset.Fields.Clear;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  FEntidadeBase.Iquery.IndexFieldNames(vIndice);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'DESCRICAO', False);
end;
function TPagar.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From PAGAR Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TPagar.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('valor')).currency:= True;
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('emissao')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('vencimento')).EditMask:= '!99/99/00;1;_';
end;
function TPagar.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

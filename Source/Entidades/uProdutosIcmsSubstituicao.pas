unit uProdutosIcmsSubstituicao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TProdutosIcmsSubstituicao = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TProdutosIcmsSubstituicao }


constructor TProdutosIcmsSubstituicao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select PI.*, P.NOME_PROD from PRODUTOS_ICMSSUBSTITUICAO PI Join PRODUTOS P On (P.COD_PROD = PI.COD_PROD) ');
end;

destructor TProdutosIcmsSubstituicao.Destroy;
begin
  inherited;
end;

class function TProdutosIcmsSubstituicao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProdutosIcmsSubstituicao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProdutosIcmsSubstituicao.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSQL + ' where PI.COD_PROD = :pParametro';
    1: vTextoSQL:= vTextoSQL + ' where P.NOME_PROD containing :pParametro';
  end;
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProdutosIcmsSubstituicao.InicializaDataSource(Value: TDataSource): iEntidade;
begin
end;

procedure TProdutosIcmsSubstituicao.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IVA')).DisplayFormat:= '#,0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('REDBASECALC')).DisplayFormat:= '#,0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ALIQUOTAINTERNA')).DisplayFormat:= '#,0.00';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ALIQUOTAINTERNA_SN')).DisplayFormat:= '#,0.00';
end;

end.

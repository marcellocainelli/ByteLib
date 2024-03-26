unit uProdutos_Grupos_Adicionais;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TProdutos_Grupos_Adicionais = class(TInterfacedObject, iEntidade)
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
{ TProdutos_Grupos_Adicionais }
constructor TProdutos_Grupos_Adicionais.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From PRODUTOS_GP_ADD ');
  InicializaDataSource;
end;
destructor TProdutos_Grupos_Adicionais.Destroy;
begin
  inherited;
end;
class function TProdutos_Grupos_Adicionais.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TProdutos_Grupos_Adicionais.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TProdutos_Grupos_Adicionais.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSql:= vTextoSql + ' WHERE ID_PRODUTO = :Parametro';
    2: vTextoSql:= vTextoSql + ' WHERE ID_GRUPO_ADICIONAIS = :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TProdutos_Grupos_Adicionais.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL + ' WHERE 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TProdutos_Grupos_Adicionais.ModificaDisplayCampos;
begin

end;
function TProdutos_Grupos_Adicionais.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

unit uAdicionais;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TAdicionais = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      function VerificaAtivosInativos(ATextoSQL: String): String;
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
{ TAdicionais }
constructor TAdicionais.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select PA.*, GA.QUANTIDADE_MAX ' +
    'from PRODUTOS_ADICIONAIS PA ' +
    'join GRUPOS_ADICIONAIS GA on (GA.ID = PA.ID_GRUPO)'
  );
  InicializaDataSource;
end;
destructor TAdicionais.Destroy;
begin
  inherited;
end;
class function TAdicionais.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TAdicionais.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TAdicionais.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSql:= vTextoSql + ' WHERE ID = :Parametro';
    2: vTextoSql:= vTextoSql + ' WHERE ID_GRUPO = :Parametro';
  end;
  vTextoSql:= VerificaAtivosInativos(vTextoSql);
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TAdicionais.InicializaDataSource(Value: TDataSource): iEntidade;
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
procedure TAdicionais.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
end;
function TAdicionais.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
function TAdicionais.VerificaAtivosInativos(ATextoSQL: String): String;
begin
  Result:= '';
  if FEntidadeBase.Inativos then begin
    if ATextoSQL.Contains('WHERE') then
      ATextoSQL:= ATextoSQL + ' and ((ATIVO = TRUE) OR (ATIVO = FALSE)) '
    else
      ATextoSQL:= ATextoSQL + ' WHERE ((ATIVO = TRUE) OR (ATIVO = FALSE)) ';
  end else begin
    if ATextoSQL.Contains('WHERE') then
      ATextoSQL:= ATextoSQL + ' and ATIVO = TRUE '
    else
      ATextoSQL:= ATextoSQL + ' WHERE ATIVO = TRUE ';
  end;
  Result:= ATextoSQL;
end;

end.

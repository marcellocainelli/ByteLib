unit uGruposAdicionais;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TGruposAdicionais = class(TInterfacedObject, iEntidade)
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
{ TGruposAdicionais }
constructor TGruposAdicionais.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From GRUPOS_ADICIONAIS ');
  InicializaDataSource;
end;
destructor TGruposAdicionais.Destroy;
begin
  inherited;
end;
class function TGruposAdicionais.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TGruposAdicionais.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TGruposAdicionais.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSql:= vTextoSql + ' WHERE ID = :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TGruposAdicionais.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL + ' WHERE 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TGruposAdicionais.ModificaDisplayCampos;
begin
end;
function TGruposAdicionais.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

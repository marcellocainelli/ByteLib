unit uPix_Bancos;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TPix_Bancos = class(TInterfacedObject, iEntidade)
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
{ TBanco }
constructor TPix_Bancos.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From PIX_BANCOS ');
  InicializaDataSource;
end;
destructor TPix_Bancos.Destroy;
begin
  inherited;
end;
class function TPix_Bancos.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TPix_Bancos.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TPix_Bancos.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL;
//  case FEntidadeBase.TipoPesquisa of
//    0: vTextoSql:= FEntidadeBase.TextoSql + 'WHERE COD_FILIAL = :pCodFilial and PIX_ID_BANCO = :pPixIdBanco';
//  end;
  FEntidadeBase.Iquery.Dataset.FieldDefs.Clear;
  FEntidadeBase.Iquery.Dataset.Fields.Clear;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TPix_Bancos.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From PIX_BANCOS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TPix_Bancos.ModificaDisplayCampos;
begin
end;
function TPix_Bancos.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

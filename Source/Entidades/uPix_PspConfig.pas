unit uPix_PspConfig;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TPix_PspConfig = class(TInterfacedObject, iEntidade)
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
constructor TPix_PspConfig.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From PIX_PSP_CONFIG ');
  InicializaDataSource;
end;
destructor TPix_PspConfig.Destroy;
begin
  inherited;
end;
class function TPix_PspConfig.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TPix_PspConfig.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TPix_PspConfig.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSql:= FEntidadeBase.TextoSql + 'WHERE COD_FILIAL = :pCodFilial and PIX_ID_BANCO = :pPixIdBanco';
  end;
  FEntidadeBase.Iquery.Dataset.FieldDefs.Clear;
  FEntidadeBase.Iquery.Dataset.Fields.Clear;
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TPix_PspConfig.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From PIX_PSP_CONFIG Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TPix_PspConfig.ModificaDisplayCampos;
begin
end;
function TPix_PspConfig.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

unit uCashback;

interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TCashback = class(TInterfacedObject, iEntidade)
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
constructor TCashback.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From CADCLI_CASHBACKS WHERE 1=1 ');
  InicializaDataSource;
end;
destructor TCashback.Destroy;
begin
  inherited;
end;
class function TCashback.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TCashback.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TCashback.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSql;
  if FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and STATUS = ''I'''
  else
    vTextoSQL:= vTextoSQL + ' and STATUS = ''A''';
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSql:= vTextoSql + ' and (DATA between :pDataInicio and :pDataFim) Order by DATA desc';
    2: vTextoSql:= vTextoSql + ' and (DATA between :pDataInicio and :pDataFim) and (COD_CLI = :pCodCli) Order by DATA desc';
    3: vTextoSql:= 'Select SUM(VALOR - VALOR_USADO) AS DISPONIVEL from CADCLI_CASHBACKS WHERE COD_CLI = :pCodCli and DATA_EXPIRA >= CURRENT_DATE'; //cashback disponivel
    4: vTextoSql:= 'Select * From CADCLI_CASHBACKS WHERE (STATUS = :pStatus) and (COD_CLI = :pCodCli) and (DATA between :pDataInicio and :pDataFim) and (COD_CLI = :pCodCli) Order by DATA desc'; //por status
  end;

  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TCashback.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From CADCLI_CASHBACKS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TCashback.ModificaDisplayCampos;
begin
end;
function TCashback.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

unit uOrdStatus;
interface
uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TOrdStatus = class(TInterfacedObject, iEntidade)
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
{ TOrdStatus }
constructor TOrdStatus.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ORD_STATUS ');
  InicializaDataSource;
end;
destructor TOrdStatus.Destroy;
begin
  inherited;
end;

class function TOrdStatus.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TOrdStatus.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TOrdStatus.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  {$IFDEF APP}
  case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + 'where CODIGO = :Parametro';
    2: vTextoSQL:= vTextoSQL + 'where STATUS LIKE :Parametro';
  end;
  {$ELSE}

  {$ENDIF}
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('STATUS');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TOrdStatus.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From ORD_STATUS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TOrdStatus.ModificaDisplayCampos;
begin
end;
function TOrdStatus.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.

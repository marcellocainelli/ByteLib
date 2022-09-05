unit uPosto_PrecoCliente;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TPosto_PrecoCliente = class(TInterfacedObject, iEntidade)
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

{ TPosto_PrecoCliente }


constructor TPosto_PrecoCliente.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select PR.*, C.NOME, P.NOME_PROD ' +
    'from PRECO PR ' +
    'Join CADCLI C On (C.CODIGO = PR.COD_CLI) ' +
    'Join PRODUTOS P On (P.COD_PROD = PR.COD_PROD)');
  InicializaDataSource;
end;

destructor TPosto_PrecoCliente.Destroy;
begin
  inherited;
end;

class function TPosto_PrecoCliente.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPosto_PrecoCliente.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPosto_PrecoCliente.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('COD_CLI');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPosto_PrecoCliente.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:=
    'select PR.*, C.NOME, P.NOME_PROD ' +
    'from PRECO PR ' +
    'Join CADCLI C On (C.CODIGO = PR.COD_CLI) ' +
    'Join PRODUTOS P On (P.COD_PROD = PR.COD_PROD) ' +
    'Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPosto_PrecoCliente.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).DisplayFormat:= '###,##0.000';
end;

function TPosto_PrecoCliente.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

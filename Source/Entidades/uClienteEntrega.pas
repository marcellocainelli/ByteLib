unit uClienteEntrega;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TClienteEntrega = class(TInterfacedObject, iEntidade)
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

{ TClienteEntrega }

constructor TClienteEntrega.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CADCLI_LOCALENTREGA where COD_CLI = :pCod_Cli');
  InicializaDataSource;
end;

destructor TClienteEntrega.Destroy;
begin

  inherited;
end;

class function TClienteEntrega.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TClienteEntrega.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TClienteEntrega.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ENDERECO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TClienteEntrega.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From CADCLI_LOCALENTREGA Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TClienteEntrega.ModificaDisplayCampos;
begin
end;

function TClienteEntrega.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

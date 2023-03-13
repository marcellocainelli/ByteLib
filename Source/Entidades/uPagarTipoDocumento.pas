unit uPagarTipoDocumento;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TPagarTipoDocumento = class(TInterfacedObject, iEntidade)
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

{ TPagarTipoDocumento }

constructor TPagarTipoDocumento.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PAGAR_TIPODOCUMENTO');

  InicializaDataSource;
end;

destructor TPagarTipoDocumento.Destroy;
begin
  inherited;
end;

class function TPagarTipoDocumento.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPagarTipoDocumento.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPagarTipoDocumento.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPagarTipoDocumento.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From PAGAR_TIPODOCUMENTO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPagarTipoDocumento.ModificaDisplayCampos;
begin

end;

function TPagarTipoDocumento.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

unit uNcmUf;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TNcmUf = class(TInterfacedObject, iEntidade)
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

{ TNcmUf }

constructor TNcmUf.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from NCM_UF_IMPOSTOS where NCM = :pNCM and UF_ORIGEM = :pUF_ORIGEM');
  InicializaDataSource;
end;

destructor TNcmUf.Destroy;
begin
  inherited;
end;

class function TNcmUf.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNcmUf.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNcmUf.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NCM');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNcmUf.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From NCM_UF_IMPOSTOS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNcmUf.ModificaDisplayCampos;
begin

end;

function TNcmUf.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.

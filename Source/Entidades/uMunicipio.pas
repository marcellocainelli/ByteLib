unit uMunicipio;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TMunicipio = class(TInterfacedObject, iEntidade)
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

{ TMunicipio }

constructor TMunicipio.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from MUNICIPIOS');

  InicializaDataSource;
end;

destructor TMunicipio.Destroy;
begin
  inherited;
end;

class function TMunicipio.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TMunicipio.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TMunicipio.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TMunicipio.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSql:= 'Select * From MUNICIPIOS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TMunicipio.ModificaDisplayCampos;
begin
end;

function TMunicipio.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
